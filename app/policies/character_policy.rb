class CharacterPolicy < ApplicationPolicy
  alias_method :character, :record

  def index?
    guest? || allowed_to?(:view_characters)
  end

  def show?
    scope.exists?(id: character.id)
  end

  def create?
    allowed_to?(:create_characters)
  end

  def update?
    (creator? && allowed_to?(:update_owned_characters)) || allowed_to?(:update_characters)
  end

  def destroy?
    (creator? && allowed_to?(:delete_owned_characters)) || allowed_to?(:delete_characters)
  end

  def permitted_attributes
    attributes  = %i(name title description avatar)
    attributes << :user_id if allowed_to?(:update_characters)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_characters)
      end
    end
  end

private

  def creator?
    current_user.try(:id) == character.user_id
  end
end
