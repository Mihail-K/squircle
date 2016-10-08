class ApplicationController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError do
    forbid
  end

  rescue_from ActiveRecord::RecordNotFound do
    not_found
  end

  rescue_from ActiveRecord::RecordInvalid,
              ActiveRecord::RecordNotSaved,
              ActiveRecord::RecordNotDestroyed do |exception|
    render json: { errors: exception.record.errors }, status: :unprocessable_entity
  end

  after_action if: -> { current_user.present? } do
    current_user.touch :last_active_at
  end

  def current_resource_owner
    @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  alias_method :current_user, :current_resource_owner

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

  def enforce_policy!
    authorize(pundit_object)
  end

  def respond_to_missing?(method_name, include_private = true)
    method_name == :"#{pundit_object_singular_name}_params" || super
  end

  def method_missing(method_name, *args, &block)
    if method_name == :"#{pundit_object_singular_name}_params"
      permitted_attributes(pundit_object)
    else
      super
    end
  end

  def allowed_to?(permission)
    current_user.try(:allowed_to?, permission)
  end

  def forbidden_to?(permission)
    current_user.try(:forbidden_to?, permission)
  end

private

  def pundit_object
    instance_variable_get("@#{pundit_object_singular_name}") ||
    instance_variable_get("@#{pundit_object_plural_name}") ||
    pundit_model
  end

  def pundit_object_singular_name
    pundit_model.model_name.singular
  end

  def pundit_object_plural_name
    pundit_model.model_name.plural
  end

  def pundit_model
    @pundit_model ||= controller_name.singularize.camelize.constantize
  end
end
