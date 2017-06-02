class TodoList < ApplicationRecord
  belongs_to :project
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
