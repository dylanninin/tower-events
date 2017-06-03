class Todo < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_context :create
  eventablize_ops_context :destroy
  eventablize_attrs_audited :due_to, :assignee_id, :status

  enum status: { open: 0, running: 1, paused: 2, completed: 3 }

  belongs_to :assignee, class_name: 'User'
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
