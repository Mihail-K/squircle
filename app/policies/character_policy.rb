class CharacterPolicy < Political::Policy
  alias_method :character, :record

  def index?
    current_user.nil? || current_user.can?(:view_characters)
  end

  def show?
    index? && scope.apply.exists?(id: character.id)
  end

  def create?
    index? && current_user.try(:can?, :create_characters)
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
