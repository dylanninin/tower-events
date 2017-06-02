class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
