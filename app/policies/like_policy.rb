# frozen_string_literal: true
class LikePolicy < ApplicationPolicy
  alias like record

  def create?
    authenticated?
  end

  def destroy?
    authenticated? && current_user == like.user
  end

  def permitted_attributes
    %i(likeable_id likeable_type)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
