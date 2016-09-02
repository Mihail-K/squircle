class BanPolicy < Political::Policy
  alias_method :ban, :record

  def index?
    authenticated?
  end

  def show?
    scope.apply.exists?(id: ban.id)
  end

  def create?
    current_user.try(:admin?)
  end

  def update?
    show? && create?
  end

  def destroy?
    show? && create?
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(reason expires_at)
      permitted << :user_id if action?('create')
      permitted << :deleted if action?('update')
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      if current_user.nil?
        scope.none
      elsif current_user.admin?
        scope.all
      else
        scope.where(user: current_user).visible
      end
    end
  end
end
