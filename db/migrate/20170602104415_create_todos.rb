class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.string :name, limit: 100, null: false
      t.text :content, limit: 10240000, null: false
      t.integer :status, default: 0
      t.date :due_to
      t.references :assignee, index: true, foreign_key: { to_table: :users }
      t.references :todo_list, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :todos, :deleted_at
  end
end
