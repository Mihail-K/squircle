class PostPolicy < Policy
  alias_method :post, :record

  def index?
    true
  end

  def show?
    scope.relation.exists? id: record.id
  end

  def create?
    return true if user.try(:admin?)
    user? && !user.banned? && !locked?
  end

  def update?
    return true if user.try(:admin?)
    author? && !user.banned? && !locked?
  end

  def destroy?
    return true if user.try(:admin?)
    author? && !user.banned? && !locked?
  end

  class Params < Policy::Params
    def permitted
      params  = %i(character_id title body)
      params += %i(conversation_id)   if action_name == 'create'
      params += %i(deleted editor_id) if user.try(:admin?)
      params
    end
  end

  class Scope < Policy::Scope
    def relation
      if user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end

private

  def author?
    user? && user.id == post.author_id
  end

  def locked?
    if klass?
      Conversation.locked.exists? id: params[:post][:conversation_id]
    else
      post.locked?
    end
  end
end
