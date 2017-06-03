class CalendarEvent < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_context :create
  eventablize_ops_context :update, verb: :edit
  eventablize_ops_context :destroy

  belongs_to :calendarable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
