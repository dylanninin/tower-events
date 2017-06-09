class Comment < ApplicationRecord
  include Eventable
  eventablize_opts actor: proc { User.current }, target: :commentable, provider: :provider, generator: :team,
                   as_json: {
                     only: [:text]
                   }
  eventablize_on :create, verb: :reply
  eventablize_on :destroy

  belongs_to :commentable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  def replied_to
    Comment.find(replied_to_id) if replied_to_id.present?
  end

  # Default provider for all events
  def provider
    case commentable_type
    when 'Todo'
      commentable.project
    when 'CalendarEvent'
      commentable.calendarable
    when 'Report'
      commentable
    end
  end
end
