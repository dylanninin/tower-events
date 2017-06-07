class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # FIXME: For soft delete
  # paranoia's soft delete is implemented by `update_columns`, and will skip callbacks
  # acts_as_paranoid
  # So, re-invent it by update attributes
  def soft_delete
    self.deleted_at = Time.now
    self.save
  end
  alias_method :destroy, :soft_delete

  scope :with_deleted, -> { unscope where: :deleted_at }

  def deleted?
    deleted_at.present?
  end

  # Event default actor, see User.current
  def eventablize_actor
    User.current
  end
end
