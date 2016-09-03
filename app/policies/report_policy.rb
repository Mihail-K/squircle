class ReportPolicy < Political::Policy
  alias_method :report, :record

  def index?
    authenticated?
  end

  def show?
    scope.apply.exists?(id: report.id)
  end

  def create?
    current_user.present? && !current_user.banned?
  end

  def update?
    return true if current_user.try(:admin?)
    current_user.present? && !current_user.banned? && report.creator_id == current_user.id && report.open?
  end

  def destroy?
    current_user.try(:admin?)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(description)
      permitted += %i(reportable_id reportable_type) if action?('create')
      permitted += %i(status deleted) if current_user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      if current_user.try(:admin?)
        scope.all
      elsif current_user.present?
        scope.visible.where(creator: current_user)
      else
        scope.none
      end
    end
  end
end
