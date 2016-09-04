class ApiController < ActionController::API
  include Political::Authority

  rescue_from ActiveRecord::RecordNotFound do
    not_found
  end

  rescue_from ActiveRecord::RecordInvalid,
              ActiveRecord::RecordNotSaved,
              ActiveRecord::RecordNotDestroyed do |exception|
    render json: { errors: exception.record.errors }, status: :unprocessable_entity
  end

  rescue_from Political::Policy::NotAllowed do
    forbid
  end

  after_action if: -> { current_user.present? } do
    current_user.touch :last_active_at
  end

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  alias_method :current_user, :current_resource_owner

  def admin?
    current_user.try :admin?
  end

  def forbid
    head :forbidden
  end

  def not_found(model = 'object')
    render json: { errors: { model => ['not found'] } }, status: :not_found
  end

  def meta_for(objects)
    {
      page:  objects.current_page,
      next:  objects.next_page,
      prev:  objects.prev_page,
      size:  objects.size,
      per:   objects.limit_value,
      total: objects.total_count,
      pages: objects.total_pages
    }
  end
end
