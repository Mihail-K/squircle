class UserPolicy < ApplicationPolicy
  alias_method :user, :record

  def me?
    authenticated?
  end

  def index?
    guest? || allowed_to?(:view_users)
  end

  def show?
    index? && scope.exists?(id: user.id)
  end

  def create?
    guest? || allowed_to?(:create_users)
  end

  def update?
    return false unless show?
    return true if allowed_to?(:update_users)
    user.id == current_user.id && allowed_to?(:update_self)
  end

  def destroy?
    return false unless show?
    return true if allowed_to?(:delete_users)
    user.id == current_user.id && allowed_to?(:delete_self)
  end

  def permitted_attributes_for_create
    %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
  end

  def permitted_attributes_for_update
    attributes  = %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
    attributes << %i(deleted) if allowed_to?(:delete_users)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.visible unless allowed_to?(:view_deleted_users)
      end
    end
  end
end
