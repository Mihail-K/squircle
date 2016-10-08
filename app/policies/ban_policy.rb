class BanPolicy < ApplicationPolicy
  alias_method :ban, :record

  def index?
    allowed_to?(:view_owned_bans)
  end

  def show?
    scope.exists?(id: ban.id)
  end

  def create?
    allowed_to?(:create_bans)
  end

  def update?
    allowed_to?(:update_bans)
  end

  def destroy?
    allowed_to?(:delete_bans)
  end

  def permitted_attributes_for_create
    %i(user_id reason expires_at)
  end

  def permitted_attributes_for_update
    attributes  = %i(reason expires_at)
    attributes << :deleted if allowed_to?(:delete_bans)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless authenticated?

      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_bans)
      end.chain do |scope|
        scope.where(user: current_user) unless allowed_to?(:view_bans)
      end.chain do |scope|
        scope.none unless allowed_to?(:view_owned_bans)
      end
    end
  end
end
