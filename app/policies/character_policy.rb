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
    return false unless show?
    return true if current_user.can?(:update_characters)
    character.user_id == current_user.id && current_user.can?(:update_owned_characters)
  end

  def destroy?
    return false unless show?
    return true if current_user.can?(:delete_characters)
    character.user_id == current_user.id && current_user.can?(:delete_owned_characters)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(name title description avatar)
      permitted << :user_id if current_user.try(:can?, :update_characters)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      scope.chain do |scope|
        scope.visible unless current_user.try(:can?, :view_deleted_characters)
      end
    end
  end
end
