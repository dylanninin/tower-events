class Event < ApplicationRecord

  class << self
    # Find event by: pass norrmal model object
    # eg:
    # => u, o = User.first, Todo.first
    # => Event.find_by(verb: 'create') # return all `create` events
    # => Event.find_by(verb: 'create', actor: u) # return all `create` events by this actor
    # => Event.find_by(verb: 'create', actor: u, object: o) # return all `create` events about that object by this actor
    # => Event.find_by # return all events, same with Event.all
    def find_by(opts = {})
      ws = []
      %i(actor object target generator provider).each do |s|
        i = opts[s]
        if i.present?
          ws << where("#{s}->'id' ? '#{i.id}' and #{s} -> 'type' ? '#{i.class.name}'")
        end
      end
      ws << where(verb: opts[:verb]) if opts[:verb].present?
      ws.inject(all, :merge)
    end

    # Audit object attribute if it has been changed
    # object: the current object being audited
    #
    # opts:
    # name: required. the attribute to be audit
    # alias: optional. the attribute alias name
    # old_value?: optional. proc to check if the old value has satisfied the condition
    # new_value?: optional. proc to check if the new value has satisfied the condition
    # value_proc: optional. proc to re-evaluate the new value after it has satisfied the condition
    def object_attribute_audited(object, opts = {})
      return nil unless opts.present?

      attr_name = opts[:name]
      return nil unless attr_name.present?

      change = object.send(:"#{attr_name}_change")
      return nil unless change.present?

      need_audit = true
      %i(old_value? new_value?).each_with_index do |v, i|
        c = opts[v]
        next if c.blank?
        unless c.call(change[i])
          need_audit = false
          break
        end
      end
      return nil unless need_audit

      {
        :attribute => opts[:alias] || attr_name,
        :old_value => opts[:value_proc] ? opts[:value_proc].call(change[0])&.as_partial_event : change[0],
        :new_value => opts[:value_proc] ? opts[:value_proc].call(change[1])&.as_partial_event : change[1]
      }
    end

    # Create event
    def create_event(opts = {})
      object = opts[:object]
      event = self.new
      event.actor = event_partial(object, :actor, opts, event_default_actor)
      event.verb = opts[:verb]
      event.object = object&.as_partial_event
      if opts[:changed_attribute].present?
        audited = object_attribute_audited(object, opts[:changed_attribute])
      else
        audited = opts[:audited]
      end
      event.object[:audited] = audited if audited.present? && event.object.present?
      event.target = event_partial(object, :target, opts)
      event.generator = event_partial(object, :generator, opts)
      event.provider = event_partial(object, :provider, opts)
      event.published = object.updated_at
      event.save
    end

    def event_partial(object, symbol, opts, default=nil)
      m = opts[symbol] || :"eventablize_#{symbol}"
      partial = default
      if object.respond_to? m
        partial = object.send m
      end
      partial&.as_partial_event
    end

    # Default user, see User.current
    def event_default_actor
      User.current
    end

  end
end
