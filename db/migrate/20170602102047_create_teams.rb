class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name, limit: 100, null: false
      t.text :description, limit: 10240000
      t.integer :status, default: 0
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :teams, :deleted_at
  end
end
