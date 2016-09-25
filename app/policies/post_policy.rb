class PostPolicy < Political::Policy
  alias_method :post, :record

  def index?
    current_user.nil? || current_user.allowed_to?(:view_posts)
  end

  def show?
    index? && scope.apply.exists?(id: post.id)
  end

  def create?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && conversation_active?
  end

  def update?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && current_user_is_author? && conversation_active?
  end

  def destroy?
    return true if current_user.try(:admin?)
    authenticated? && !current_user.banned? && current_user_is_author? && conversation_active?
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
      if current_user.try(:allowed_to?, :view_deleted_posts)
        scope.all
      else
        scope.visible
      end
    end
  end

private

  def current_user_is_author?
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
