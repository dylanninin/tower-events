class Todo < ApplicationRecord
  enum status: { open: 0, running: 1, paused: 2, completed: 3 }

  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  # Serialize as partial event
  def as_partial_event
    as_json only: %i[name]
  end

  after_create_commit :add_event_after_create
  def add_event_after_create
    Event.create_event actor: User.current, verb: :create, object: self,
                       provider: project, generator: team
  end

  around_update :add_event_after_assign
  def add_event_after_assign
    yield
    changed_attribute = {
      name: :assignee_id,
      alias: :assignee,
      old_value?: ->(v) { v.nil? },
      value_proc: ->(v) { User.where(id: v).first }
    }
    Event.create_event actor: User.current, verb: :assign, object: self,
                       target: assignee, changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_reassign
  def add_event_after_reassign
    yield
    changed_attribute = {
      name: :assignee_id,
      alias: :assignee,
      old_value?: ->(v) { v.present? },
      new_value?: ->(v) { v.present? },
      value_proc: ->(v) { User.where(id: v).first }
    }
    Event.create_event actor: User.current, verb: :reassign, object: self,
                       target: assignee, changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_set_due_to
  def add_event_after_set_due_to
    yield
    changed_attribute = {
      name: :due_to
    }
    Event.create_event actor: User.current, verb: :set_due_to, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_run
  def add_event_after_run
    yield
    changed_attribute = {
      name: :status,
      new_value?: ->(v) { v == 'running' }
    }
    Event.create_event actor: User.current, verb: :run, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_pause
  def add_event_after_pause
    yield
    changed_attribute = {
      name: :status,
      new_value?: ->(v) { v == 'paused' }
    }
    Event.create_event actor: User.current, verb: :pause, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_complete
  def add_event_after_complete
    yield
    changed_attribute = {
      name: :status,
      new_value?: ->(v) { v == 'complete' }
    }
    Event.create_event actor: User.current, verb: :complete, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_reopen
  def add_event_after_reopen
    yield
    changed_attribute = {
      name: :status,
      new_value?: ->(v) { v == 'open' }
    }
    Event.create_event actor: User.current, verb: :reopen, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_recover
  def add_event_after_recover
    yield
    changed_attribute = {
      name: :deleted_at,
      new_value?: ->(v) { v.nil? }
    }
    Event.create_event actor: User.current, verb: :recover, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end

  around_update :add_event_after_destroy
  def add_event_after_destroy
    yield
    changed_attribute = {
      name: :deleted_at,
      old_value?: ->(v) { v.nil? },
      new_value?: ->(v) { v.present? }
    }
    Event.create_event actor: User.current, verb: :destroy, object: self,
                       changed_attribute: changed_attribute,
                       provider: project, generator: team
  end
end
