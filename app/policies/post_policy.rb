class PostPolicy < Political::Policy
  alias_method :post, :record

  def index?
    true
  end

  def show?
    scope.apply.exists?(id: post.id)
  end

  def create?
    return true if current_user.try(:admin?)
    current_user.present? && !current_user.banned? && conversation_active?
  end

  def update?
    return true if current_user.try(:admin?)
    current_user.present? && author? && !current_user.banned? && conversation_active?
  end

  def destroy?
    return true if current_user.try(:admin?)
    current_user.present? && author? && !current_user.banned? && conversation_active?
  end

  class Parameters < Political::Policy::Parameters
    def permitted
      permitted  = %i(character_id title body)
      permitted += %i(conversation_id)   if action?('create')
      permitted += %i(deleted editor_id) if current_user.try(:admin?)
      permitted
    end
  end

  class Scope < Political::Policy::Scope
    def apply
      if current_user.try(:admin?)
        scope.all
      else
        scope.visible
      end
    end
  end

private

  def author?
    post.author_id == current_user.id
  end

  def conversation_active?
    if model?
      return false unless params[:post].respond_to?(:[])
      Conversation.active.exists?(id: params[:post][:conversation_id])
    else
      post.conversation.active?
    end
  end
end
