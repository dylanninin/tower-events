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

    # Todo verb: :create, :destroy, :run, :pause, :complete, :recover, :reopen
    def normalized_ops_on_todo(object, verb, opts = {})
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      if opts[:provider]
        event.provider = (object.send opts[:provider]).as_partial_event
      else
        event.provider = object.as_partial_event
      end
      event.save
    end

    # FIXME: Injecting attributes into object introduces inconsistence.
    def audited_on_todo(object, verb, audited, opts = {})
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.object[:audited] = audited
      if opts[:target]
        event.target = (object.send opts[:target]).as_partial_event
      end
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    # Team verb: :create, :destroy
    def normalized_ops_on_team(object, verb, opts = {})
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    # Project verb: :create, :destroy
    def normalized_ops_on_project(object, verb, opts = {})
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    # FIXME: Report/Calendar ops just like project
    alias_method :normalized_ops_on_report, :normalized_ops_on_project
    alias_method :normalized_ops_on_calendar, :normalized_ops_on_project

    # CalendarEvent verb: :create, :destroy, :edit
    def normalized_ops_on_calendar_event(object, verb, opts = {})
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.calendarable.as_partial_event
      event.save
    end

    # Comment verb: :reply, :like
    def normalized_ops_on_comment(object, verb, opts = {})
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.target = object.commentable.as_partial_event
      event.generator = object.team.as_partial_event
      case object.commentable_type
      when 'Todo'
        event.provider = object.commentable.project.as_partial_event
      when 'CalendarEvent'
        event.provider = object.commentable.calendarable.as_partial_event
      when 'Report'
        event.provider = object.commentable.as_partial_event
      else
        raise ArgumentError.new("unknown commentable_type: #{object.commentable_type}")
      end
      event.save
    end

  end
end
