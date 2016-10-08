class ConversationPolicy < ApplicationPolicy
  alias_method :conversation, :record

  def index?
    true
  end

  def show?
    scope.exists?(id: conversation.id)
  end

  def create?
    index? && allowed_to?(:create_conversations)
  end

  def update?
    show? && modifiable? && (
      allowed_to?(:update_conversations) ||
      (author? && allowed_to?(:update_owned_conversations))
    )
  end

  def destroy?
    show? && modifiable? && (
      allowed_to?(:delete_conversations) ||
      (author? && allowed_to?(:delete_owned_conversations))
    )
  end

  def permitted_attributes_for_create
    attributes  = [:section_id, posts_attributes: %i(character_id title body)]
    attributes += %i(deleted locked) if current_user.try(:admin?)
    attributes
  end

  def permitted_attributes_for_update
    attributes  = [ ]
    attributes += %i(section_id deleted locked) if current_user.try(:admin?)
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

  def modifiable?
    !conversation.locked? || allowed_to?(:lock_conversations)
  end
end
