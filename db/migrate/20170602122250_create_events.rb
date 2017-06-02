class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :content
      t.string :verb, limit: 20, null: false
      t.json :actor
      t.json :object
      t.json :target
      t.json :generator
      t.json :provider
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :events, :deleted_at
  end
end
