# frozen_string_literal: true
class NotificationPolicy < ApplicationPolicy
  alias notification record

  def index?
    authenticated?
  end

  def update?
    notification.user == current_user
  end

  def destroy?
    notification.user == current_user
  end

  def permitted_attributes_for_update
    %i(read dismissed)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: current_user)
    end
  end
end
