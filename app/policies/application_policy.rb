class ApplicationPolicy
  attr_reader :current_user
  attr_reader :record

  def initialize(current_user, record)
    @current_user = current_user
    @record       = record
  end

  def index?
    false
  end

  def show?
    scope.exists?(id: record.id)
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(current_user, record.class.all)
  end

  def permitted_attributes
    []
  end

  class Scope
    attr_reader :current_user
    attr_reader :scope

    def initialize(current_user, scope)
      @current_user = current_user
      @scope        = scope
    end

    def resolve
      scope
    end

  protected

    def authenticated?
      current_user.present?
    end

    def guest?
      current_user.nil?
    end

    def allowed_to?(permission)
      authenticated? && current_user.allowed_to?(permission)
    end

    def forbidden_to?(permission)
      authenticated? && current_user.forbidden_to?(permission)
    end
  end

protected

  def authenticated?
    current_user.present?
  end

  def guest?
    current_user.nil?
  end

  def allowed_to?(permission)
    authenticated? && current_user.allowed_to?(permission)
  end

  def forbidden_to?(permission)
    authenticated? && current_user.forbidden_to?(permission)
  end
end
