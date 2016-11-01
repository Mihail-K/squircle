# frozen_string_literal: true
class RemoveTitleFromPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :title, :string, index: true
  end
end
