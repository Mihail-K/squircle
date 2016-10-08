class SectionPolicy < ApplicationPolicy
  alias_method :section, :record

  def index?
    true
  end

  def show?
    scope.exists?(id: section)
  end

  def create?
    allowed_to?(:create_sections)
  end

  def update?
    allowed_to?(:update_sections)
  end

  def destroy?
    allowed_to?(:delete_sections)
  end

  def permitted_attributes
    %i(title description deleted)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_sections)
      end
    end
  end
end
