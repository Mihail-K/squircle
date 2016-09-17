class UserPolicy < Political::Policy
  alias_method :user, :record

  def me?
    authenticated?
  end

  def index?
    current_user.nil? || current_user.allowed_to?(:view_users)
  end

  def show?
    index? && scope.apply.exists?(id: user.id)
  end

  def create?
    current_user.nil? || current_user.allowed_to?(:create_users)
  end

  def update?
    return false unless show?
    return true if current_user.allowed_to?(:update_users)
    user.id == current_user.id && current_user.allowed_to?(:update_self)
  end

  def destroy?
    return false unless show?
    return true if current_user.allowed_to?(:delete_users)
    user.id == current_user.id && current_user.allowed_to?(:delete_self)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
      permitted += %i(deleted) if action?('update') && current_user.try(:allowed_to?, :delete_users)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      scope.chain do |scope|
        scope.visible unless current_user.try(:allowed_to?, :view_deleted_users)
      end
    end
  end
end
