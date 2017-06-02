class CreateTodoLists < ActiveRecord::Migration[5.1]
  def change
    create_table :todo_lists do |t|
      t.string :name, limit: 100, null: false
      t.integer :status, default: 0
      t.references :project, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :todo_lists, :deleted_at
  end
end
