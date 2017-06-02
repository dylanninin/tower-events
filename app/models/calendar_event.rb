class CalendarEvent < ApplicationRecord
  belongs_to :calendarable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
