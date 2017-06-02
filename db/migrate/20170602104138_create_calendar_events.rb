class CreateCalendarEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :calendar_events do |t|
      t.string :name, limit: 100, null: false
      t.date :start_date
      t.date :end_date
      t.integer :status, default: 0
      t.references :calendarable, index: true, polymorphic: true
      t.references :team, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :calendar_events, :deleted_at
  end
end
