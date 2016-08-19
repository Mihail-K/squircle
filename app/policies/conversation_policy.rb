class ConversationPolicy < Political::Policy
  alias_method :conversation, :record

  def index?
    true
  end

  def show?
    scope.apply.exists? id: conversation.id
  end

  def create?
    return true if user.try(:admin?)
    authenticated? && !user.try(:banned?)
  end

  def update?
    return true if user.try(:admin?)
    authenticated? && author? && !user.banned? && !locked?
  end

  def destroy?
    user.try(:admin?)
  end

  class Parameters < Political::Policy::Parameters
    def permitted
      permitted  = [ ]
      permitted << { posts_attributes: %i(character_id title body) } if create?
      permitted += %i(deleted locked) if user.try(:admin?)
      permitted
    end

    def create?
      params[:action] == 'create'
    end
  end

  class Scope < Political::Policy::Scope
    def apply
      if user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end

protected

  def author?
    user.try(:id) == conversation.author_id
  end

  def locked?
    conversation.locked?
  end
end
