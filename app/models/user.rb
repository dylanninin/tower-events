class User < ApplicationRecord
  has_secure_password

  include Eventable
  eventablize_opts as_json: { only: [:name, :avatar] }

  # Thread scope: current_user
  def self.current
    Thread.current[:current_user]
  end

  def self.current=(user)
    Thread.current[:current_user] = user
  end
end
