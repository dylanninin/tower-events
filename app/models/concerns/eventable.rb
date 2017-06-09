# encoding: utf-8

module Eventable
  extend ActiveSupport::Concern

  included do
    # FIXME: For soft delete.
    # paranoia's soft delete is implemented by `update_columns`, and will skip callbacks
    # So, re-invent it
    # => soft delete by update attributes
    # => see `eventablize_soft_delete` in `eventablize_ops_context`
    def soft_delete
      self.deleted_at = Time.now
      save
    end
    alias_method :destroy, :soft_delete

    # Find Object's events
    def events
      Event.find_by object: self
    end

    # To partial event: json format
    def as_partial_event
      opts = self.class.instance_variable_get(:@_eventablize_opts) || {}
      json = as_json Event.resolve_value(self, opts[:as_json])
      json[:created_at] = created_at
      json[:updated_at] = updated_at
      # TODO: Attribute type should be reserved
      json[:type] = self.class.name
      # FIXME: Convert id to string, for gin index in PostgreSQL
      json[:id] = id.to_s
      json
    end

    private

    # To audit attrs
    def callback_around_update_attrs_changed
      yield
      base = self.class.instance_variable_get(:@_eventablize_opts) || {}
      audits = self.class.instance_variable_get(:@_eventablize_on_attrs_changed) || {}
      audits.keys.each do |v|
        opts = base.merge audits[v]
        k = opts[:attr]
        change = send(:"#{k}_change")
        next unless change.present?

        need_audit = true
        %i[old_value? new_value?].each_with_index do |v, i|
          c = opts[v]
          next if c.blank?
          unless c.call(change[i])
            need_audit = false
            break
          end
        end

        # Process next audit
        next unless need_audit

        # Generate event
        # FIXME: Get referenced object by field like 'assignee_id'
        # => attr_alias is an alias for attr
        # => value_proc is the proc to get value of the attr
        opts[:parameters] = {
          attribute: opts[:attr_alias] || k,
          old_value: Event.resolve_value(change[0], opts[:value_proc] || :self),
          new_value: Event.resolve_value(change[1], opts[:value_proc] || :self)
        }
        opts[:object] = self
        Event.create_event(**opts)
      end
    end
  end

  AVALIABLE_OPS_CONTEXT_SCOPE = %i[create update destroy].freeze
  module ClassMethods
    # Define global opts for current eventablized model
    # opts:
    # actor：Object|Symbol|Proc, required. 指定 event.actor, 即当前操作者
    # object: Object|Symbol|Proc, required. 指定 event.object，即当前操作的首要对象
    # target：Object|Symbol|Proc, optional. 指定 event.target，即当前操作的目标对象
    # provider: Object|Symbol|Proc, optional. 指定 event.provider, 属于 Context
    # generator: Object|Symbol|Proc, optional. 指定 event.generator, 属于 Context
    # as_json: Hash, optional. 指定以上参数在序列化时的选项
    def eventablize_opts(opts = {})
      instance_variable_set(:@_eventablize_opts, opts)
    end

    # Define any ops context for create events
    # examples
    # * eventablize_on :create will create a event after create
    # * eventablize_on :destroy will create a event after destroy
    # * eventablize_on :update will create a event after update
    # * eventablize_on :update, verb: :reopen, attr: :status, old_value?: -> (v) { v == 'completed' },  new_value?: -> (v) { v == 'open' } will create a event after status has been changed from completed to open
    # more examples see Todo.rb
    #
    # ctx:
    # Symbol. 主要是 :create, :destroy, :update
    #
    # opts:
    # actor：Object|Symbol|Proc, required. 指定 event.actor, 即当前操作者
    # verb: String, required, 指定 event.verb
    # object: Object|Symbol|Proc, required. 指定 event.object，即当前操作的首要对象
    # target：Object|Symbol|Proc, optional. 指定 event.target，即当前操作的目标对象
    # provider: Object|Symbol|Proc, optional. 指定 event.provider, 属于 Context
    # generator: Object|Symbol|Proc, optional. 指定 event.generator, 属于 Context
    # attr: 即要跟踪变化的属性.
    # attr_alias. 属性别名，若不指定默认为 attr 取值。例如 attr: :assignee_id, alias: :assignee，则在 event.parameters[attribute] = :assignee
    # old_value?：Proc. 指定数据属性取值变化时，旧的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    # new_value?：Proc. 指定数据属性取值变化时，新的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    # value_proc：Proc. 指定 event.parameters 中 old|new_value 的求值 proc，若不指定默认为原始值
    def eventablize_on(ctx, opts = {})
      raise ArgumentError, "unsupported context: #{ctx}" unless AVALIABLE_OPS_CONTEXT_SCOPE.include? ctx

      return eventablize_on_attrs_changed(**opts) if opts[:attr].present?
      return eventablize_on_soft_delete if ctx == :destroy

      base = instance_variable_get(:@_eventablize_opts) || {}
      opts = base.merge opts
      send(:after_commit, proc {
        opts[:verb] ||= ctx
        opts[:object] = self
        Event.create_event(**opts)
      }, on: ctx)
    end

    private

    # Define any audited attributes
    def eventablize_on_attrs_changed(opts = {})
      audited = instance_variable_get(:@_eventablize_on_attrs_changed) || {}
      audited[opts[:verb]] = opts
      instance_variable_set(:@_eventablize_on_attrs_changed, audited)

      # Avoid duplicated callbacks
      registered = instance_variable_get(:@_eventablize_on_attrs_changed_registered)
      if registered.blank?
        send(:around_update, :callback_around_update_attrs_changed)
        instance_variable_set(:@_eventablize_on_attrs_changed_registered, true)
      end
    end

    # For soft delete
    def eventablize_on_soft_delete
      opts = { verb: :destroy, attr: :deleted_at, old_value?: ->(v) { v.nil? }, new_value?: ->(v) { v.present? } }
      eventablize_on_attrs_changed(**opts)
    end
  end
end
