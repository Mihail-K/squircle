# frozen_string_literal: true
class PostPolicy < ApplicationPolicy
  alias post record

  def index?
    guest? || allowed_to?(:view_posts)
  end

  def show?
    scope.exists?(id: post)
  end

  def create?
    allowed_to?(:create_posts)
  end

  def update?
    return false if post.conversation.locked? unless allowed_to?(:lock_conversations)
    (author? && allowed_to?(:update_owned_posts)) || allowed_to?(:update_posts)
  end

  def destroy?
    return false if post.conversation.locked? unless allowed_to?(:lock_conversations)
    (author? && allowed_to?(:delete_owned_posts)) || allowed_to?(:delete_posts)
  end

  def permitted_attributes_for_create
    attributes =  %i(conversation_id title body)
    attributes << :character_id if allowed_to?(:use_characters)
    attributes << :deleted      if allowed_to?(:delete_conversations)
    attributes
  end

  def permitted_attributes_for_update
    attributes =  %i(title body)
    attributes << :character_id if allowed_to?(:use_characters)
    attributes << :deleted      if allowed_to?(:delete_conversations)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_posts)
      end.chain do |scope|
        scope.joins(:conversation)
             .merge(Conversation.not_deleted) unless allowed_to?(:view_deleted_conversations)
      end.chain do |scope|
        scope.joins(:section)
             .merge(Section.not_deleted) unless allowed_to?(:view_deleted_sections)
      end
    end
  end

private

  def author?
    post.author_id == current_user.try(:id)
  end
end
