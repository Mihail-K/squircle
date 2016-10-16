# frozen_string_literal: true
class AddVisiblePostsCountToConversations < ActiveRecord::Migration[5.0]
  class Conversation < ActiveRecord::Base
    has_many :posts, -> { where(deleted: false) }
  end
  class Post < ActiveRecord::Base
    belongs_to :conversation
  end
  def change
    add_column :conversations, :visible_posts_count, :integer, null: false, default: 0
    Conversation.find_each do |conversation|
      conversation.update_columns visible_posts_count: conversation.posts.count
    end unless reverting?
  end
end
