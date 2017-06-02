class Access < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :accessable, polymorphic: true
  belongs_to :creator, class_name: 'User'
end
