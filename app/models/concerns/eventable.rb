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

    def as_ops_context_create
      puts "create #{self.class.name}"
      m = :"create_#{self.class.name.underscore}"
      Event.send(m, self)
    end

    # TODO: Fix inconsistence
    def as_ops_context_update
      puts "edit #{self.class.name}"
      m = :"edit_#{self.class.name.underscore}"
      Event.send(m, self)
    end

    # BUG: destroy callback not triggered after soft delete
    # https://github.com/rubysherpas/paranoia/issues/217
    def as_ops_context_destroy
      puts "destroy #{self.class.name}"
      m = :"destroy_#{self.class.name.underscore}"
      Event.send(m, self)
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

    # Define any ops context
    def eventablize_ops_contexts(*ctxs)
      cx = ctxs.uniq
      diff = cx - AVALIABLE_OPS_CONTEXT_SCOPE
      raise ArgumentError.new("unsupported contexts: #{diff}") if diff.present?
      instance_variable_set(:@_eventablize_ops_contexts, cx)
      cx.each do |i|
        puts "#{self.class.name} after_commit :as_ops_context_#{i} on #{i}"
        self.send(:after_commit, :"as_ops_context_#{i}", on: i)
      end
    end
  end

end
