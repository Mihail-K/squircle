class ReportPolicy < ApplicationPolicy
  alias_method :report, :record

  def index?
    allowed_to?(:view_owned_reports)
  end

  def show?
    scope.exists?(id: report)
  end

  def create?
    allowed_to?(:create_reports)
  end

  def update?
    (creator? && allowed_to?(:update_owned_reports)) || allowed_to?(:update_reports)
  end

  def destroy?
    (creator? && allowed_to?(:delete_owned_reports)) || allowed_to?(:delete_reports)
  end

  def permitted_attributes_for_create
    %i(reportable_id reportable_type description)
  end

  def permitted_attributes_for_update
    attributes  = %i(description)
    attributes << :status  if allowed_to?(:update_reports)
    attributes << :deleted if allowed_to?(:delete_reports)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_reports)
      end.chain do |scope|
        scope.where(creator: current_user) unless allowed_to?(:view_reports)
      end.chain do |scope|
        scope.none unless allowed_to?(:view_owned_reports)
      end
    end
  end

private

  def creator?
    current_user.try(:id) == report.creator_id
  end
end
