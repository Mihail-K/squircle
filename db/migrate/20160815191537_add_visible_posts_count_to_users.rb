class AddVisiblePostsCountToUsers < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
    has_many :posts, -> { where(deleted: false) }, foreign_key: :author_id
  end
  class Post < ActiveRecord::Base
    belongs_to :user, foreign_key: :author_id
  end
  def change
    add_column :users, :visible_posts_count, :integer, null: false, default: 0
    User.find_each do |user|
      user.update_columns visible_posts_count: user.posts.count
    end
  end
end
