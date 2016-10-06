class ConversationPolicy < ApplicationPolicy
  alias_method :conversation, :record

  def index?
    true
  end

  def show?
    scope.exists?(id: conversation.id)
  end

  def create?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned?
  end

  def update?
    return true if current_user.try(:admin?)
    authenticated? && author? && !current_user.banned? && !locked?
  end

  def destroy?
    current_user.try(:admin?)
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
      if current_user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end

protected

  def author?
    current_user.try(:id) == conversation.author_id
  end

  def locked?
    conversation.locked?
  end
end
