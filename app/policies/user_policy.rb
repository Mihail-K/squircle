class UserPolicy < Political::Policy
  def index?
    true
  end

  def show?
    scope.apply.exists? id: record.id
  end

  def create?
    user.nil? || user.admin?
  end

  def update?
    user.try(:admin?) || user.try(:id) == record.id
  end

  def destroy?
    user.try(:admin?) || user.try(:id) == record.id
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(email date_of_birth display_name first_name last_name password password_confirmation avatar)
      permitted += %i(deleted admin) if user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      if user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end
end
