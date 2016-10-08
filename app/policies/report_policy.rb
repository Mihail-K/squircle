class ReportPolicy < ApplicationPolicy
  alias_method :report, :record

  def index?
    authenticated?
  end

  def show?
    index? && scope.exists?(id: report.id)
  end

  def create?
    authenticated? && !current_user.banned?
  end

  def update?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && report.creator_id == current_user.id && report.open?
  end

  def destroy?
    current_user.try(:admin?)
  end

  def permitted_attributes_for_create
    %i(reportable_id reportable_type description)
  end

  def permitted_attributes_for_update
    attributes  = %i(description)
    attributes += %i(status deleted) if current_user.try(:admin?)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if current_user.try(:admin?)
        scope.all
      elsif authenticated?
        scope.not_deleted.where(creator: current_user)
      else
        scope.none
      end
    end
  end
end
