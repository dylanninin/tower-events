class Report < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'

  after_create_commit :add_event_after_create
  def add_event_after_create
    Event.create_event(verb: :create, object: self)
  end

  around_update :add_event_after_destroy
  def add_event_after_destroy
    Event.create_event(verb: :destroy, object: self)
  end

  # Serialized attrs for created event
  def eventablize_serializer_attrs
    %i(name)
  end

  # Default provider for all events
  def eventablize_provider
    self
  end

  # Default generator for all events
  def eventablize_generator
    team
  end
end
