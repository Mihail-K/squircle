class SectionPolicy < Political::Policy
  alias_method :section, :record

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: section)
  end

  def create?
    user.try(:admin?)
  end

  def update?
    user.try(:admin?)
  end

  def destroy?
    user.try(:admin?)
  end

  class Parameters < Political::Parameters
    def permitted
      %i(title description deleted)
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
