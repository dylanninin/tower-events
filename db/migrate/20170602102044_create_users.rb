class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :avatar
      t.string :name, limit: 50, null: false
      t.integer :status, default: 0
      t.string :email, null: false
      t.string :password_digest
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :deleted_at
  end
end
