class SectionPolicy < Political::Policy
  alias_method :section, :record

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: section)
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

  class Parameters < Political::Parameters
    def permitted
      %i(title description deleted)
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
