class ChangeVerbLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :verb, :string, limit: 100, null: false
  end
end
