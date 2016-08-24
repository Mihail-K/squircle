class ReportPolicy < Political::Policy
  alias_method :report, :record

  def index?
    true
  end

  def show?
    scope.apply.exists? id: report.id
  end

  def create?
    user.present? && !user.banned?
  end

  def update?
    return true if user.try(:admin?)
    user.present? && !user.banned? && report.creator_id == user.id && report.open?
  end

  def destroy?
    user.try(:admin?)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(reportable_id reportable_type description)
      permitted << :status if user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      if user.try(:admin?)
        scope.all
      elsif user.present?
        scope.visible.where(creator: user)
      else
        scope.none
      end
    end
  end
end
