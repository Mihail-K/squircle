class ConversationPolicy < Political::Policy
  alias_method :conversation, :record

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: conversation.id)
  end

  def create?
    return true if current_user.try(:admin?)
    current_user.present? && !current_user.banned?
  end

  def update?
    return true if current_user.try(:admin?)
    current_user.present? && author? && !current_user.banned? && !locked?
  end

  def destroy?
    current_user.try(:admin?)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = [ ]
      permitted << :section_id if action?('create') || current_user.try(:admin?)
      permitted << { posts_attributes: %i(character_id title body) } if action?('create')
      permitted += %i(deleted locked) if current_user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
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
