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
          ws << where("#{s} ->> 'id' = '#{i.id}' and #{s} ->> 'type' = '#{i.class.name}'")
        end
      end
      ws << where(verb: opts[:verb]) if opts[:verb].present?
      ws.inject(all, :merge)
    end

    # Create event
    def create_event(opts = {})
      object = opts[:object]
      event = self.new
      event.actor = event_partial(object, :actor, opts, event_default_actor)
      event.verb = opts[:verb]
      event.object = object&.as_partial_event
      event.object[:audited] = opts[:audited] if opts[:audited].present? && event.object.present?
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

  # TODO: Title can be removed
  # For flexibility, title has not been persisted
  def title
    words = []
    words << actor['name']
    case verb
    when 'create', 'destroy', 'run', 'pause', 'complete', 'reopen', 'recover'
      words << verb
      words << object['type']
      words << ':'
      words << object['name']
    when 'set_due_to'
      words << verb
      words << "from #{object['audited']['old_value']}"
      words << "to #{object['audited']['new_value']}"
      words << ':'
      words << object['name']
    when 'assign'
      words << verb
      words << target['name']
      words << ":"
      words << object['name']
    when 'reassign'
      words << object['audited']['old_value']['name']
      words << object['type']
      words << 'to'
      words << object['audited']['new_value']['name']
      words << ':'
      words << object['name']
    when 'reply'
      words << verb
      words << target['type']
      words << ':'
      words << target['name']
    end
    words.join(' ')
  end

  # TODO: Content can be removed
  # For flexibility, content has not been persisted
  def content
    case verb
    when 'reply'
      object['text']
    end
  end

end
