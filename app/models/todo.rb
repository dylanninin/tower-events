class Todo < ApplicationRecord

  enum status: { open: 0, running: 1, paused: 2, completed: 3 }

  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  after_create_commit :add_event_after_create_todo
  def add_event_after_create_todo
    Event.create_event(verb: :create, object: self)
  end

  around_update :add_event_after_assign_todo
  def add_event_after_assign_todo
    yield
    changed_attribute = {
      name: :assignee_id,
      alias: :assignee,
      old_value?: -> (v) { v.nil? },
      value_proc: -> (v) { User.where(id: v).first }
    }
    Event.create_event(verb: :assign, object: self, target: :assignee, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_reassign_todo
  def add_event_after_reassign_todo
    yield
    changed_attribute = {
      name: :assignee_id,
      alias: :assignee,
      old_value?: -> (v) { v.present? },
      new_value?: -> (v) { v.present? },
      value_proc: -> (v) { User.where(id: v).first }
    }
    Event.create_event(verb: :reassign, object: self, target: :assignee, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_set_due_to_todo
  def add_event_after_set_due_to_todo
    yield
    changed_attribute = {
      name: :due_to
    }
    Event.create_event(verb: :set_due_to, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_run_todo
  def add_event_after_run_todo
    yield
    changed_attribute = {
      name: :status,
      new_value?: -> (v) { v == 'running' }
    }
    Event.create_event(verb: :run, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_pause_todo
  def add_event_after_pause_todo
    yield
    changed_attribute = {
      name: :status,
      new_value?: -> (v) { v == 'paused' }
    }
    Event.create_event(verb: :pause, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_complete_todo
  def add_event_after_complete_todo
    yield
    changed_attribute = {
      name: :status,
      new_value?: -> (v) { v == 'complete' }
    }
    Event.create_event(verb: :complete, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_reopen_todo
  def add_event_after_reopen_todo
    yield
    changed_attribute = {
      name: :status,
      new_value?: -> (v) { v == 'open' }
    }
    Event.create_event(verb: :reopen, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_recover_todo
  def add_event_after_recover_todo
    yield
    changed_attribute = {
      name: :deleted_at,
      new_value?: -> (v) { v.nil? }
    }
    Event.create_event(verb: :recover, object: self, changed_attribute: changed_attribute)
  end

  around_update :add_event_after_destroy_todo
  def add_event_after_destroy_todo
    yield
    changed_attribute = {
      name: :deleted_at,
      old_value?: -> (v) { v.nil? },
      new_value?: -> (v) { v.present? }
    }
    Event.create_event(verb: :destroy, object: self, changed_attribute: changed_attribute)
  end

  def eventablize_serializer_attrs
    %i(name)
  end

  # Default provider for all events
  def eventablize_provider
    project
  end

  # Default generator for all events
  def eventablize_generator
    team
  end
end
