class FixPostsCountOnConversations < ActiveRecord::Migration[5.0]
  def up
    Conversation.find_each do |conversation|
      posts_count = scope.where(conversation: conversation).count
      conversation.update_columns(posts_count: posts_count)
    end
  end

private

  def scope
    @policy ||= PostPolicy.new(user, Post.new).scope
  end

  def user
    @user ||= User.new(roles: [Role.find_by!(name: :user)])
  end
end
