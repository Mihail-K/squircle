class PostPolicy < Political::Policy
  alias_method :post, :record

  def index?
    true
  end

  def show?
    scope.apply.exists? id: record.id
  end

  def create?
    return true if user.try(:admin?)
    authenticated? && !user.banned? && !locked?
  end

  def update?
    return true if user.try(:admin?)
    author? && !banned? && !locked?
  end

  def destroy?
    return true if user.try(:admin?)
    author? && !banned? && !locked?
  end

  class Parameters < Political::Policy::Parameters
    def permitted
      permitted  = %i(character_id title body)
      permitted += %i(conversation_id)   if params[:action] == 'create'
      permitted += %i(deleted editor_id) if user.try(:admin?)
      permitted
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

private

  def author?
    authenticated? && user.id == post.author_id
  end

  def banned?
    authenticated? && user.banned?
  end

  def locked?
    if model?
      return false unless params[:post].respond_to? :[]
      Conversation.locked.exists? id: params[:post][:conversation_id]
    else
      post.conversation.locked?
    end
  end
end
