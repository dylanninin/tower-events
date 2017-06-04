class AlterEventsColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :actor, :jsonb, null: false
    change_column :events, :object, :jsonb, null: false
    change_column :events, :target, :jsonb
    change_column :events, :provider, :jsonb
    change_column :events, :generator, :jsonb
  end
end
