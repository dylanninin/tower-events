class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  def replied_to
    Comment.find(replied_to_id) if replied_to_id.present?
  end

  after_create_commit :add_event_after_create
  def add_event_after_create
    Event.create_event(verb: :reply, object: self)
  end

  around_update :add_event_after_destroy
  def add_event_after_destroy
    Event.create_event(verb: :destroy, object: self)
  end

  # Serialized attrs for created event
  def eventablize_serializer_attrs
    %i(text)
  end

  # Default target for all events
  def eventablize_target
    commentable
  end

  # Default provider for all events
  def eventablize_provider
    case commentable_type
    when 'Todo'
      provider = commentable.project
    when 'CalendarEvent'
      provider = commentable.calendarable
    when 'Report'
      provider = commentable
    else
      raise ArgumentError.new("unknown commentable_type: #{object.commentable_type}")
    end
    provider
  end

  # Default generator for all events
  def eventablize_generator
    team
  end
end
