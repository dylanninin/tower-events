class CreateAccesses < ActiveRecord::Migration[5.1]
  def change
    create_table :accesses do |t|
      t.references :user, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.string :role, limit: 50, null: false
      t.references :accessable, index: true, polymorphic: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :accesses, :deleted_at
  end
end
