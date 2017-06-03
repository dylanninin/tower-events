class Report < ApplicationRecord
  include Eventable
  eventablize_serializer_attrs :name
  eventablize_ops_contexts :create

  belongs_to :team
  belongs_to :creator, class_name: 'User'
end
