# frozen_string_literal: true
class UserPolicy < ApplicationPolicy
  alias user record

  def me?
    authenticated?
  end

  def index?
    guest? || allowed_to?(:view_users)
  end

  def show?
    scope.exists?(id: user)
  end

  def create?
    guest? || allowed_to?(:create_users)
  end

  def update?
    (current_user == user && allowed_to?(:update_self)) || allowed_to?(:update_users)
  end

  def destroy?
    (current_user == user && allowed_to?(:delete_self)) || allowed_to?(:delete_users)
  end

  def permitted_attributes_for_create
    %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
  end

  def permitted_attributes_for_update
    attributes =  %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
    attributes << :deleted if allowed_to?(:delete_users)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_users)
      end
    end
  end
end
