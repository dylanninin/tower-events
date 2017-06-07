class Team < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  # Serialize as partial event
  def as_partial_event
    as_json only: %i[name]
  end

  after_create_commit :add_event_after_create
  def add_event_after_create
    Event.create_event actor: User.current, verb: :create, object: self,
                       provider: self, generator: self
  end

  around_update :add_event_after_destroy
  def add_event_after_destroy
    Event.create_event actor: User.current, verb: :destroy, object: self,
                       provider: self, generator: self
  end
end
