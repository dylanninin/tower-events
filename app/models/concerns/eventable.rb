module Eventable
  extend ActiveSupport::Concern

  included do
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
        %i(old_value new_value).each_with_index do |v, i|
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
        # TODO: Get referenced object by field like 'assignee_id'
        audited = {
          :attribute => k,
          :old_value => change[0],
          :new_value => change[1]
        }
        %i(object verb aduited).each {|i| opts.delete(i) }
        m = :"audited_on_#{self.class.name.underscore}"
        Event.send(m, self, v, audited, **opts)
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

    # Define any ops context: :create, :update, :destroy
    def eventablize_ops_context(ctx, opts = {})
      raise ArgumentError.new("unsupported context: #{ctx}") unless AVALIABLE_OPS_CONTEXT_SCOPE.include? ctx

      return eventablize_attrs_audited(**opts) if opts[:attr].present?

      verb = opts[:verb] || ctx
      self.send(:after_commit, proc {
        m = :"normalized_ops_on_#{self.class.name.underscore}"
        %i(object verb).each {|i| opts.delete(i) }
        Event.send(m, self, verb, **opts)
      }, on: ctx)
    end
  end

end
