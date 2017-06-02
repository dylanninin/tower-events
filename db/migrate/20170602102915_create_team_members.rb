class CreateTeamMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: true
      t.references :member, null: false, index: true, foreign_key: { to_table: :users }
      t.references :creator, index: true, foreign_key: { to_table: :users }
      t.string :role, limit: 50, null: false
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :team_members, :deleted_at
  end
end
