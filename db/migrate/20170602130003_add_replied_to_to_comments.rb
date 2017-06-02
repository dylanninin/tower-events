class AddRepliedToToComments < ActiveRecord::Migration[5.1]
  def change
    add_reference :comments, :replied_to, index: true, references: :comments
  end
end
