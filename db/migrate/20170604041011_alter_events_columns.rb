class AlterEventsColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :actor, :jsonb, null: false
    change_column :events, :object, :jsonb, null: false
    change_column :events, :target, :jsonb, null: false
    change_column :events, :provider, :jsonb, null: false
    change_column :events, :generator, :jsonb, null: false
  end
end
