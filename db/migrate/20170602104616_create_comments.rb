class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :text, limit: 10240000, null: false
      t.references :commentable, index: true, polymorphic: true
      t.references :team, index: true, foreign_key: true
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :comments, :deleted_at
  end
end
