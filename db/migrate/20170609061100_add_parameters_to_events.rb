class AddParametersToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :parameters, :jsonb
  end
end
