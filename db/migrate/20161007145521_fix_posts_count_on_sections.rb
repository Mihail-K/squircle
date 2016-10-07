class FixPostsCountOnSections < ActiveRecord::Migration[5.0]
  def up
    Section.find_each do |section|
      posts_count = section.posts.visible.count
      section.update_columns(posts_count: posts_count)
    end
  end
end
