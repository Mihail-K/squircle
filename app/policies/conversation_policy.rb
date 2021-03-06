# frozen_string_literal: true
class ConversationPolicy < ApplicationPolicy
  alias conversation record

  def index?
    true
  end

  def show?
    scope.exists?(id: conversation)
  end

  def create?
    allowed_to?(:create_conversations)
  end

  def update?
    return false if conversation.locked? unless allowed_to?(:lock_conversations)
    (author? && allowed_to?(:update_owned_conversations)) || allowed_to?(:update_conversations)
  end

  def destroy?
    return false if conversation.locked? unless allowed_to?(:lock_conversations)
    (author? && allowed_to?(:delete_owned_conversations)) || allowed_to?(:delete_conversations)
  end

  def permitted_attributes_for_create
    attributes =  [:section_id, :title, posts_attributes: [:character_id, :body]]
    attributes << :locked  if allowed_to?(:lock_conversations)
    attributes << :deleted if allowed_to?(:delete_conversations)
    attributes
  end

  def permitted_attributes_for_update
    attributes =  [:title]
    attributes << :section_id if allowed_to?(:move_conversations)
    attributes << :locked     if allowed_to?(:lock_conversations)
    attributes << :deleted    if allowed_to?(:delete_conversations)
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.chain do |scope|
        scope.not_deleted unless allowed_to?(:view_deleted_conversations)
      end.chain do |scope|
        scope.joins(:section)
             .merge(Section.not_deleted) unless allowed_to?(:view_deleted_sections)
      end
    end
  end

protected

  def author?
    current_user.try(:id) == conversation.author_id
  end
end
