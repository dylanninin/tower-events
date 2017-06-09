class CalendarEvent < ApplicationRecord
  include Eventable
  eventablize_opts actor: proc { User.current }, provider: :calendarable, team: :team,
                   as_json: {
                     only: [:name]
                   }
  eventablize_on :create
  eventablize_on :update, verb: :edit
  eventablize_on :destroy

  belongs_to :calendarable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
