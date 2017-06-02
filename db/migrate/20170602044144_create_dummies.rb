class CreateDummies < ActiveRecord::Migration[5.1]
  def change
    create_table :dummies do |t|
      t.string :title
      t.string :description
      t.string :icon
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :dummies, :deleted_at
  end
end
