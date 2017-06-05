module Eventable
  extend ActiveSupport::Concern

  included do
    # FIXME: For soft delete. `update_columns` will skip callbacks
    # So, re-invent it
    # => soft delete by update attributes
    # => see `eventablize_soft_delete` in `eventablize_ops_context`
    def soft_delete
      self.deleted_at = Time.now
      self.save
    end
    alias_method :destroy, :soft_delete

    # To partial event: json format
    def as_partial_event
      keys = self.class.instance_variable_get(:@_eventablize_serializer_attrs) || []
      keys.concat %i(id creator_id created_at updated_at)
      json = as_json(only: keys)
      json[:type] = self.class.name
      json
    end

    # To audit attrs
    def callback_around_update_attrs_audited
      yield
      audits = self.class.instance_variable_get(:@_eventablize_attrs_audited) || {}
      audits.keys.each do |v|
        opts = audits[v]
        k = opts[:attr]
        change = self.send(:"#{k}_change")
        next unless change.present?

        need_audit = true
        %i(old_value? new_value?).each_with_index do |v, i|
          c = opts[v]
          next if c.blank?
          # p opts, v, i, c, change, c.call(change[i])
          unless c.call(change[i])
            need_audit = false
            break
          end
        end

        # Process next audit
        next unless need_audit

        # Generate event
        # FIXME: Get referenced object by field like 'assignee_id'
        # => attr_alias is an alias for audited attr
        # => value_proc is the proc to get value of the attr
        opts[:audited] = {
          :attribute => opts[:attr_alias] || k,
          :old_value => opts[:value_proc] ? opts[:value_proc].call(change[0])&.as_partial_event : change[0],
          :new_value => opts[:value_proc] ? opts[:value_proc].call(change[1])&.as_partial_event : change[1]
        }
        opts[:object] = self
        Event.create_event(**opts)
      end
    end
  end

  AVALIABLE_OPS_CONTEXT_SCOPE = %i(create update destroy)
  module ClassMethods
    # Define any attrs as the partial event
    def eventablize_serializer_attrs(*attrs)
      instance_variable_set(:@_eventablize_serializer_attrs, attrs.uniq)
    end

    # Define any audited attributes
    def eventablize_attrs_audited(opts = {})
      audited = instance_variable_get(:@_eventablize_attrs_audited) || {}
      audited[opts[:verb]] = opts
      instance_variable_set(:@_eventablize_attrs_audited, audited)

      # Avoid duplicated callbacks
      registered = instance_variable_get(:@_eventablize_attrs_audited_registered)
      if registered.blank?
        self.send(:around_update, :callback_around_update_attrs_audited)
        instance_variable_set(:@_eventablize_attrs_audited_registered, true)
      end
    end

    # For soft delete
    def eventablize_soft_delete
      opts = { verb: :destroy, attr: :deleted_at, old_value: -> (v) { v.nil? },  new_value: -> (v) { v.present? } }
      eventablize_attrs_audited(**opts)
    end

    # Define any ops context for create events
    # examples
    # * eventablize_ops_context :create will create a event after create
    # * eventablize_ops_context :destroy will create a event after destroy
    # * eventablize_ops_context :update will create a event after update
    # * eventablize_ops_context :update, verb: :reopen, attr: :status, old_value?: -> (v) { v == 'completed' },  new_value?: -> (v) { v == 'open' } will create a event after status has been changed from completed to open
    # more examples see Todo.rb
    #
    # ctx:
    # Symbol. 主要是 :create, :destroy, :update
    #
    # opts:
    # verb: Symbol. 指定 event.verb，默认同 ctx.
    # target：Symbol. 指定 event.target
    # provider: Symbol. 默认为 :eventablize_provider
    # generator: Symbol. 默认为 :eventablize_generator
    # actor：Symbol. 即当前操作者，默认直接从 User.current 中获取，为 Thread.current 变量
    # attr：Symbol. 即要跟踪变化的属性.
    # attr_alias：Symbol. 属性别名，若不指定默认为 attr 取值。例如 attr: :assignee_id, attr_alias: :assignee，则在 audited[attribute] = :assignee
    # value_proc：Proc. 指定 event.object.audited 中 old|new_value 的求值 proc，若不指定默认为原始值
    # old_value?：Proc. 指定数据属性取值变化时，旧的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    # new_value?：Proc. 指定数据属性取值变化时，新的取值是否满足当前 verb 的要求。如 open|reopen|complete 等动作均是对 Todo.status 属性操作，此时需要验证以作区分。
    #
    def eventablize_ops_context(ctx, opts = {})
      raise ArgumentError.new("unsupported context: #{ctx}") unless AVALIABLE_OPS_CONTEXT_SCOPE.include? ctx

      return eventablize_attrs_audited(**opts) if opts[:attr].present?
      return eventablize_soft_delete if ctx == :destroy

      self.send(:after_commit, proc {
        opts[:verb] ||= ctx
        opts[:object] = self
        Event.create_event(**opts)
      }, on: ctx)
    end
  end

end
