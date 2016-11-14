# frozen_string_literal: true
class FriendshipLoader < Loader
  def for(friends)
    Friendship.where(user: current_user, friend: friends)
              .map { |friendship| [friendship.friend_id, friendship] }
              .to_h if current_user.present?
  end
end
