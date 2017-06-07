class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  def replied_to
    Comment.find(replied_to_id) if replied_to_id.present?
  end

  # Serialize as partial event
  def as_partial_event
    as_json only: %i[text]
  end

  after_create_commit :add_event_after_create
  def add_event_after_create
    Event.create_event actor: User.current, verb: :reply, object: self,
                       target: commentable, provider: provider, generator: team
  end

  around_update :add_event_after_destroy
  def add_event_after_destroy
    Event.create_event actor: User.current, verb: :destroy, object: self,
                       provider: provider, generator: team
  end

  # Default provider for all events
  def provider
    case commentable_type
    when 'Todo'
      provider = commentable.project
    when 'CalendarEvent'
      provider = commentable.calendarable
    when 'Report'
      provider = commentable
    else
      raise ArgumentError, "unknown commentable_type: #{object.commentable_type}"
    end
    provider
  end
end
