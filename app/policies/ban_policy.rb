class BanPolicy < Political::Policy
  alias_method :ban, :record

  def index?
    authenticated?
  end

  def show?
    scope.apply.exists? id: ban.id
  end

  def create?
    user.try(:admin?)
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
      if user.nil?
        scope.none
      elsif user.admin?
        scope.all
      else
        scope.where(user_id: user)
      end
    end
  end
end
