class CharacterPolicy < ApplicationPolicy
  alias_method :character, :record

  def index?
    guest? || allowed_to?(:view_characters)
  end

  def show?
    index? && scope.exists?(id: character.id)
  end

  def create?
    index? && allowed_to?(:create_characters)
  end

  def update?
    return false unless show?
    return true if allowed_to?(:update_characters)
    character.user_id == current_user.id && allowed_to?(:update_owned_characters)
  end

  def destroy?
    return false unless show?
    return true if allowed_to?(:delete_characters)
    character.user_id == current_user.id && allowed_to?(:delete_owned_characters)
  end

  def permitted_attributes
    attributes  = %i(name title description avatar)
    attributes << :user_id if allowed_to?(:update_characters)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.visible unless allowed_to?(:view_deleted_characters)
      end
    end
  end
end
