class RemoveVisiblePostsCountFromSections < ActiveRecord::Migration[5.0]
  def change
    remove_column :sections, :visible_posts_count, :integer, null: false, default: 0
  end
end
