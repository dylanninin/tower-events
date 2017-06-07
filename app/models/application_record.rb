class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # FIXME: For soft delete
  # paranoia's soft delete is implemented by `update_columns`, and will skip callbacks
  # acts_as_paranoid
  # So, re-invent it by update attributes
  def soft_delete
    self.deleted_at = Time.now
    save
  end
  alias destroy soft_delete

  scope :with_deleted, -> { unscope where: :deleted_at }

  def deleted?
    deleted_at.present?
  end
end
