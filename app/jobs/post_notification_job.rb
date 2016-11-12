# frozen_string_literal: true
class PostNotificationJob < ApplicationJob
  queue_as :low

  def perform(post_id)
    post = Post.find(post_id)
    post.subscribers.where.not(id: post.author_id).find_each do |user|
      post.notifications.find_or_create_by(user: user) do |notification|
        notification.title = I18n.t('notifications.post', name: post.author.display_name,
                                                          conversation: post.conversation.title)
      end
    end
  end
end
