class UserDisplayNameJob < ApplicationJob
  queue_as :high

  def perform(user_id)
    user = User.find(user_id)
    Like.where(user: user).update_all(display_name: user.display_name, updated_at: Time.current)
  end
end
