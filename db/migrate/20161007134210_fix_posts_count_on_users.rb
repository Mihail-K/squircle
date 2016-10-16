# frozen_string_literal: true
class FixPostsCountOnUsers < ActiveRecord::Migration[5.0]
  def up
    User.find_each do |user|
      posts_count = user.posts.visible.count
      user.update_columns(posts_count: posts_count)
    end
  end
end
