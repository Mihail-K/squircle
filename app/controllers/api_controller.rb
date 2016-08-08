class ApiController < ActionController::API
  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  alias_method :current_user, :current_resource_owner

  def current_admin
    current_user if current_user.try :admin?
  end
end
