class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :name, limit: 100, null: false
      t.text :content, limit: 10240000, null: false
      t.integer :status, default: 0
      t.references :team, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :reports, :deleted_at
  end
end
