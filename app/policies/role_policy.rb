class RolePolicy < ApplicationPolicy
  alias_method :role, :record

  def index?
    authenticated?
  end

  def show?
    scope.exists?(id: role)
  end
end
