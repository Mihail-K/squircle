class BanPolicy < Political::Policy
  alias_method :ban, :record

  def index?
    authenticated? && can_view_bans?
  end

  def show?
    index? && scope.apply.exists?(id: ban.id)
  end

  def create?
    index? && current_user.can?(:create_bans)
  end

  def update?
    show? && current_user.can?(:update_bans)
  end

  def destroy?
    show? && current_user.can?(:delete_bans)
  end

  class Parameters < Political::Parameters
    def permitted
      permitted  = %i(reason expires_at)
      permitted << :user_id if action?('create')
      permitted << :deleted if action?('update') && current_user.can?(:delete_bans)
      permitted
    end
  end

  class Scope < Political::Scope
    def apply
      return scope.none unless authenticated? && can_view_bans?

      scope.chain do |scope|
        scope.none unless current_user.can?(:view_owned_bans)
      end.chain do |scope|
        scope.where(user: current_user) unless current_user.can?(:view_bans)
      end.chain do |scope|
        scope.visible unless current_user.can?(:view_deleted_bans)
      end
    end

  private

    def can_view_bans?
      %i(view_owned_bans view_bans view_deleted_bans).any? do |view_bans|
        current_user.can?(view_bans)
      end
    end
  end

private

  def can_view_bans?
    %i(view_owned_bans view_bans view_deleted_bans).any? do |view_bans|
      current_user.can?(view_bans)
    end
  end
end
