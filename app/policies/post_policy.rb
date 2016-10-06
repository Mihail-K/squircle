class PostPolicy < ApplicationPolicy
  alias_method :post, :record

  def index?
    guest? || allowed_to?(:view_posts)
  end

  def show?
    index? && scope.exists?(id: post.id)
  end

  def create?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned?
  end

  def update?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && current_user_is_author? && conversation_active?
  end

  def destroy?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && current_user_is_author? && conversation_active?
  end

  def permitted_attributes_for_create
    attributes  = %i(conversation_id character_id title body)
    attributes += %i(deleted editor_id) if current_user.try(:admin?)
    attributes
  end

  def permitted_attributes_for_update
    attributes  = %i(character_id title body)
    attributes += %i(deleted editor_id) if current_user.try(:admin?)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if current_user.try(:allowed_to?, :view_deleted_posts)
        scope.all
      else
        scope.visible
      end
    end
  end

private

  def current_user_is_author?
    post.author_id == current_user.id
  end

  def conversation_active?
    post.conversation.active?
  end
end
