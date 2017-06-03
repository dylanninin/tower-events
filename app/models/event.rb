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

    def create_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'create'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.team.as_partial_event
      event.save
    end

    def delete_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'delete'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.team.as_partial_event
      event.save
    end

    def complete_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'complete'
      event.object = object.as_partial_event
      event.generator = oject.team.as_partial_event
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

    def reply_todo(object)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = 'reply'
      event.object = object.as_partial_event
      event.target = object.commentable.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    def recover_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'recover'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    def reopen_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'reopen'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    def run_todo(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'run'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.project.as_partial_event
      event.save
    end

    def create_team(object)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = 'create'
      event.object = object.as_partial_event
      event.generator = object.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    def create_project(object)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = 'create'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.as_partial_event
      event.save
    end

    def create_calendar_event(object)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = 'create'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.calendarable.as_partial_event
      event.save
    end

    def reply_calendar_event(object, target)
      event = self.new
      event.actor = object.creator.as_partial_event
      event.verb = 'reply'
      event.object = object.as_partial_event
      event.target = target.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = target.calendarable.as_partial_event
      event.save
    end

    def edit_calendar_event(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'edit'
      event.object = object.as_partial_event
      event.generator = object.team.as_partial_event
      event.provider = object.calendarable.as_partial_event
      event.save
    end

    def like_comment(object)
      event = self.new
      event.actor = User.current.as_partial_event
      event.verb = 'like'
      event.object = object.as_partial_event
      event.target = object.commentable.as_partial_event
      event.generator = object.team.as_partial_event
      case object.commentable_type
      when 'Todo'
        event.provider = object.project.as_partial_event
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
