class RenamePosterToAuthorInPosts < ActiveRecord::Migration[5.0]
  def change
    rename_column :posts, :poster_id, :author_id
  end
end
