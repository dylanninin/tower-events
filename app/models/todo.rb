class Todo < ApplicationRecord
  belongs_to :assignee, class_name: 'User'
  belongs_to :todo_list
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
