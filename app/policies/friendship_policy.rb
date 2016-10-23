class FriendshipPolicy < ApplicationPolicy
  alias friendship record

  def create?
    authenticated?
  end

  def destroy?
    friendship.user == current_user
  end

  def permitted_attributes
    [:friend_id]
  end
end
