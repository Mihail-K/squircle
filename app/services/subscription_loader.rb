# frozen_string_literal: true
class SubscriptionLoader < Loader
  def for(conversations)
    Subscription.where(user: current_user, conversation: conversations)
                .map { |subscription| [subscription.conversation_id, subscription] }
                .to_h if current_user.present?
  end
end
