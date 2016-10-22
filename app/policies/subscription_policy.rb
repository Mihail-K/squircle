class SubscriptionPolicy < ApplicationPolicy
  alias subscription record

  def index
    authenticated?
  end

  def show?
    scope.exists?(id: subscription)
  end

  def create?
    allowed_to?(:create_subscriptions)
  end

  def destroy?
    (subscription.user == current_user && allowed_to?(:delete_owned_subscriptions)) ||
    allowed_to?(:delete_subscriptions)
  end

  def permitted_attributes
    [:conversation_id]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: current_user)
    end
  end
end
