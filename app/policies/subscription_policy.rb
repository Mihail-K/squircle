# frozen_string_literal: true
class SubscriptionPolicy < ApplicationPolicy
  alias subscription record

  def index?
    authenticated?
  end

  def show?
    scope.exists?(id: subscription)
  end

  def create?
    authenticated?
  end

  def destroy?
    subscription.user == current_user
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
