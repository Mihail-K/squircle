class ChangePostableReferenceToConversationReferenceInPosts < ActiveRecord::Migration[5.0]
  def change
    rename_column :posts, :postable_id, :conversation_id
    remove_column :posts, :postable_type, :string
    add_index :posts, :conversation_id
    add_foreign_key :posts, :conversations
  end
end
