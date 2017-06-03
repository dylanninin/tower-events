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
end
