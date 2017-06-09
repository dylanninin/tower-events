class Todo < ApplicationRecord
  include Eventable
  eventablize_opts actor: Proc.new { User.current }, provider: :project, generator: :team,
                   as_json: {
                     only: [:name],
                     include: [:creator]
                   }
  eventablize_on :create
  eventablize_on :destroy

  eventablize_on :update, verb: :set_due_to, attr: :due_to
  eventablize_on :update, verb: :assign, target: :assignee, attr: :assignee_id, attr_alias: :assignee, value_proc: -> (v) { User.where(id: v).first }, old_value?: -> (v) { v.nil? }, new_value?: -> (v) { v.present? }
  eventablize_on :update, verb: :reassign, target: :assignee, attr: :assignee_id, attr_alias: :assignee, value_proc: -> (v) { User.where(id: v).first }, old_value?: -> (v) { v.present? }, new_value?: -> (v) { v.present? }
  eventablize_on :update, verb: :run, attr: :status, new_value?: -> (v) { v == 'running' }
  eventablize_on :update, verb: :pause, attr: :status, new_value?: -> (v) { v == 'paused' }
  eventablize_on :update, verb: :complete, attr: :status, new_value?: -> (v) { v == 'completed' }
  eventablize_on :update, verb: :reopen, attr: :status, old_value?: -> (v) { v == 'completed' },  new_value?: -> (v) { v == 'open' }
  eventablize_on :update, verb: :recover, attr: :deleted_at, old_value?: -> (v) { v.present? },  new_value?: -> (v) { v.nil? }

  enum status: { open: 0, running: 1, paused: 2, completed: 3 }

  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
