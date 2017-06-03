class Comment < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :text
  eventablize_ops_context :create, verb: :reply
  eventablize_ops_context :destroy

  belongs_to :commentable, polymorphic: true
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  def replied_to
    Comment.find(replied_to_id) if replied_to_id.present?
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
