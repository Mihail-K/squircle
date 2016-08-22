class CharacterPolicy < Political::Policy
  alias_method :character, :record

  def index?
    true
  end

  def show?
    scope.apply.exists? id: character.id
  end

  def create?
    user.present? && (user.admin? || !user.banned?)
  end

  def update?
    return true if user.try(:admin?)
    user.present? && !user.banned? && character.user_id == user.id
  end

  def destroy?
    update?
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(name title description avatar)
      permitted << :user_id if user.try(:admin?)
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
