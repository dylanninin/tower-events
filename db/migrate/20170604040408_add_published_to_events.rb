class AddPublishedToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :published, :timestamp, null: false
  end
end
