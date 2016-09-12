class RolePolicy < Political::Policy
  def index?
    authenticated?
  end
end
