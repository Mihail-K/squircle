# frozen_string_literal: true
class AddLikesCountToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :likes_count, :integer, null: false, default: 0
  end
end
