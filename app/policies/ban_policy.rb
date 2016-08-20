class BanPolicy < Political::Policy
  alias_method :ban, :record

  def index?
    authenticated?
  end

  def show?
    scope.apply.exists?(id: ban.id)
  end

  def create?
    user.try(:admin?)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  class Parameters < Political::Parameters
    def permitted
      %i(user_id reason expires_at)
    end
  end

  class Scope < Political::Scope
    def apply
      if user.nil?
        scope.none
      elsif user.admin?
        admin_scope
      else
        scope.where(user_id: user)
      end
    end

  private

    def admin_scope
      scope = self.scope.all
      scope = scope.where(user_id: params[:user_id]) if params.key? :user_id
      scope
    end
  end
end
