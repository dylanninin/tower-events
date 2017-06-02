class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member, class_name: 'User'
  belongs_to :creator, class_name: 'User'
end
