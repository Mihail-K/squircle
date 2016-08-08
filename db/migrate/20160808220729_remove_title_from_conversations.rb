class RemoveTitleFromConversations < ActiveRecord::Migration[5.0]
  def change
    remove_column :conversations, :title, :string
  end
end
