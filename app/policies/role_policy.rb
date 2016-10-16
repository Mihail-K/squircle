# frozen_string_literal: true
class RolePolicy < ApplicationPolicy
  alias role record

  def index?
    authenticated?
  end

  def show?
    scope.exists?(id: role)
  end
end
