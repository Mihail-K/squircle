class ApiController < ActionController::API
  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  alias_method :current_user, :current_resource_owner

  def current_admin
    current_user if admin?
  end

  def admin?
    current_user.try :admin?
  end

  def errors(object)
    render json: { errors: (object.respond_to?(:errors) ? object.errors : object) },
           status: :unprocessable_entity
  end

  def forbid(body = { nothing: true })
    render({ status: :forbidden }.merge(body))
  end
end
