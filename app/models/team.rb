class Team < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_contexts :create, :destroy

  belongs_to :creator, class_name: 'User'
end
