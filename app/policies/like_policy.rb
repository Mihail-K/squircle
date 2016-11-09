# frozen_string_literal: true
class LikePolicy < ApplicationPolicy
  alias like record

  def create?
    authenticated?
  end

  def destroy?
    authenticated?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
