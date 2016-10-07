class RemoveVisiblePostsCountFromConversations < ActiveRecord::Migration[5.0]
  def change
    remove_column :conversations, :visible_posts_count, :integer, null: false, default: 0
  end
end
