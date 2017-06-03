class Team < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_context :create
  eventablize_ops_context :destroy

  belongs_to :creator, class_name: 'User'

  def eventablize_generator
    self
  end

  def eventablize_provider
    self
  end
end
