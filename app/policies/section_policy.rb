class SectionPolicy < ApplicationPolicy
  alias_method :section, :record

  def index?
    true
  end

  def show?
    scope.exists?(id: section)
  end

  def create?
    current_user.try(:admin?)
  end

  def update?
    current_user.try(:admin?)
  end

  def destroy?
    current_user.try(:admin?)
  end

  def permitted_attributes
    %i(title description deleted)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if current_user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end
end
