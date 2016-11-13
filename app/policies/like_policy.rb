# frozen_string_literal: true
class LikePolicy < ApplicationPolicy
  alias like record

  def create?
    allowed_to?(:create_likes)
  end

  def destroy?
    (current_user == like.user && allowed_to?(:delete_owned_likes)) || allowed_to?(:delete_likes)
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
