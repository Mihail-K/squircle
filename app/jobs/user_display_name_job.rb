# frozen_string_literal: true
class UserDisplayNameJob < ApplicationJob
  queue_as :high

  def perform(user_id)
    @user = User.find(user_id)
    [likes, posts].each do |objects|
      objects.update_all(display_name: @user.display_name, updated_at: Time.current)
    end
  end

private

  def likes
    Like.where(user: @user)
  end

  def posts
    Post.where(author: @user)
  end
end
