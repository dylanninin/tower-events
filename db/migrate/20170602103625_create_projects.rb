class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name, limit: 100, null: false
      t.text :description, limit: 10240000
      t.integer :status, default: 0
      t.references :team, null: false, index: true, foreign_key: true
      t.references :creator, null: false, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :projects, :deleted_at
  end
end
