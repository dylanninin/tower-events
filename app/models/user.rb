class User < ApplicationRecord
  has_secure_password

  # Thread scope: current_user
  def self.current
    Thread.current[:current_user]
  end

  def self.current=(user)
    Thread.current[:current_user] = user
  end

  # Serialized attrs for created event
  def eventablize_serializer_attrs
    %i(name avatar)
  end
end
