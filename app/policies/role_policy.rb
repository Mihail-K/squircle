class RolePolicy < ApplicationPolicy
  alias_method :role, :record

  def index?
    authenticated?
  end

  def show?
    index? && scope.exists?(id: role.id)
  end
end
