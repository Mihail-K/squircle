class UserPolicy < Political::Policy
  alias_method :user, :record

  def me?
    authenticated?
  end

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: user.id)
  end

  def create?
    current_user.nil? || current_user.admin?
  end

  def update?
    current_user.try(:admin?) || current_user.try(:id) == record.id
  end

  def destroy?
    current_user.try(:admin?) || current_user.try(:id) == record.id
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
      permitted += %i(deleted role) if current_user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      if current_user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end
end
