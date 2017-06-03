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
    def as_attrs_audited
      yield
      attrs = self.class.instance_variable_get(:@_eventablize_attrs_audited) || []
      attrs.uniq.each do |x|
        change = self.send(:"#{x}_change")
        if change.present?
          puts "changed attrs: #{x}, #{change}"
          # TODO: Add event
        end
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
    def eventablize_attrs_audited(*attrs)
      instance_variable_set(:@_eventablize_attrs_audited, attrs.uniq)
      self.send(:around_update, :as_attrs_audited)
    end

    # Define any ops context: :create, :update, :destroy
    def eventablize_ops_context(ctx, opts = {})
      raise ArgumentError.new("unsupported context: #{ctx}") unless AVALIABLE_OPS_CONTEXT_SCOPE.include? ctx
      verb = opts[:verb] || ctx
      self.send(:after_commit, proc {
        m = :"normalized_ops_on_#{self.class.name.underscore}"
        Event.send(m, self, verb)
      }, on: ctx)
    end
  end

end
