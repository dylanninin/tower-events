class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # For soft delete
  acts_as_paranoid
end
