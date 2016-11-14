# frozen_string_literal: true
class FriendshipLoader < Loader
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def for(friends)
    Friendship.where(user: user, friend: friends)
              .map { |friendship| [friendship.friend_id, friendship] }
              .to_h if user.present?
  end
end
