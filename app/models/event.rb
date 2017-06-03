class Event < ApplicationRecord

  class << self
    # Find event by
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

    # The normalized ops on model
    def add_event(opts = {})
      object = opts[:object]
      event = self.new
      event.actor = event_partial(object, :actor, opts, event_default_actor)
      event.verb = opts[:verb]
      event.object = opts[:object]&.as_partial_event
      event.object[:audited] = opts[:audited] if opts[:audited].present? && event.object.present?
      event.target = event_partial(object, :target, opts)
      # TODO: Hardcode generator: object.team
      event.generator = event_partial(object, :generator, opts, object.try(:team))
      event.provider = event_partial(object, :provider, opts)
      event.save
    end

    def event_partial(object, symbol, opts, default=nil)
      m = opts[symbol]
      m ||= :"eventablize_#{symbol}"
      partial = default
      if object.respond_to? m
        partial = object.send m
      end
      partial&.as_partial_event
    end

    def event_default_actor
      User.current
    end

  end
end
