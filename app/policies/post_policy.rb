class PostPolicy < ApplicationPolicy
  alias_method :post, :record

  def index?
    guest? || allowed_to?(:view_posts)
  end

  def show?
    index? && scope.exists?(id: post.id)
  end

  def create?
    allowed_to?(:create_posts)
  end

  def update?
    show? && can_modify? && (
      allowed_to?(:update_posts) || (author? && allowed_to?(:update_owned_posts))
    )
  end

  def destroy?
    show? && can_modify? && (
      allowed_to?(:delete_posts) || (author? && allowed_to?(:delete_owned_posts))
    )
  end

  def permitted_attributes_for_create
    attributes  = %i(conversation_id character_id title body)
    attributes << :deleted if allowed_to?(:delete_conversations)
    attributes << :editor_id if current_user.try(:admin?)
    attributes
  end

  def permitted_attributes_for_update
    attributes  = %i(character_id title body)
    attributes << :deleted if allowed_to?(:delete_conversations)
    attributes << :editor_id if current_user.try(:admin?)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_posts)
      end.chain do |scope|
        scope.joins(:conversation)
             .merge(Conversation.visible) unless allowed_to?(:view_deleted_conversations)
      end
    end
  end

private

  def author?
    post.author_id == current_user.try(:id)
  end

  def can_modify?
    !post.conversation.locked? || allowed_to?(:lock_conversations)
  end
end
