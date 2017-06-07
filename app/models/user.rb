class User < ApplicationRecord
  has_secure_password

  # Thread scope: current_user
  def self.current
    Thread.current[:current_user]
  end

  def self.current=(user)
    Thread.current[:current_user] = user
  end

  # Serialize as partial event
  def as_partial_event
    as_json only: %i[name avatar]
  end
end
