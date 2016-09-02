class CharacterPolicy < Political::Policy
  alias_method :character, :record

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: character.id)
  end

  def create?
    current_user.present? && (current_user.admin? || !current_user.banned?)
  end

  def update?
    return true if current_user.try(:admin?)
    current_user.present? && !current_user.banned? && character.user_id == current_user.id
  end

  def destroy?
    update?
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(name title description avatar)
      permitted << :user_id if current_user.try(:admin?)
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
