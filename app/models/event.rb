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
    def normalized_ops_on_todo(object, verb)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.team.as_partial_event
      event.save
    end

    def assign_todo(object, assignee)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'assign'
      event.object = object.as_partial_event
      event.target = assignee.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    # FIXME: Injecting attributes into object introduces inconsistence.
    def reassign_todo(object, old_assignee)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'reassign'
      object = object.as_partial_event
      object['audited_attribute'] = 'assignee'
      object['old_value'] = old_assignee.as_partial_event
      object['new_value'] = object.assignee.as_partial_event
      event.target = object.assignee.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    # FIXME: Refine `set_due` to `set_due_to`
    def set_due_to_todo(object, old_due_to)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'set_due_to'
      o = object.as_partial_event
      o['audited_attribute'] = 'due_to'
      o['old_value'] = old_due_to.as_partial_event
      o['new_value'] = object.due_to.as_partial_event
      event.object = o
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    def duplicate_todo(object, times)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'duplicate'
      o = object.as_partial_event
      o['audited_attribute'] = 'times'
      o['old_value'] = 0
      o['new_value'] = times
      event.object = o
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    # Team verb: :create, :destroy
    def normalized_ops_on_team(object, verb)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    # Project verb: :create, :destroy
    def normalized_ops_on_project(object, verb)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    # CalendarEvent verb: :create, :destroy, :edit
    def normalized_ops_on_calendar_event(object, verb)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = verb
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.calendarable.as_partial_event
      event.save
    end

    # Comment verb: :reply, :like
    def normalized_ops_on_comment(object, verb)
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
