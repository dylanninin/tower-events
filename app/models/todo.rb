class Todo < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_context :create
  eventablize_ops_context :destroy
  # FIXME: For consistency, set_due rename to set_due_to
  eventablize_ops_context :update, verb: :set_due_to, attr: :due_to
  eventablize_ops_context :update, verb: :assign, target: :assignee, attr: :assignee_id, attr_alias: :assignee, value_proc: -> (v) { User.where(id: v).first }, old_value?: -> (v) { v.nil? }, new_value?: -> (v) { v.present? }
  eventablize_ops_context :update, verb: :reassign, target: :assignee, attr: :assignee_id, attr_alias: :assignee, value_proc: -> (v) { User.where(id: v).first }
  eventablize_ops_context :update, verb: :run, attr: :status, new_value?: -> (v) { v == 'running' }
  eventablize_ops_context :update, verb: :pause, attr: :status, new_value?: -> (v) { v == 'paused' }
  eventablize_ops_context :update, verb: :complete, attr: :status, new_value?: -> (v) { v == 'completed' }
  eventablize_ops_context :update, verb: :reopen, attr: :status, old_value?: -> (v) { v == 'completed' },  new_value?: -> (v) { v == 'open' }
  eventablize_ops_context :update, verb: :recover, attr: :deleted_at, old_value?: -> (v) { v.present? },  new_value?: -> (v) { v.nil? }

  enum status: { open: 0, running: 1, paused: 2, completed: 3 }

  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  # Default provider for all events
  def eventablize_provider
    project
  end

  # Default generator for all events
  def eventablize_generator
    team
  end
end
