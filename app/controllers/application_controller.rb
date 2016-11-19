# frozen_string_literal: true
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

  alias current_user current_resource_owner

  def forbid
    head :forbidden
  end

  def load(name, object)
    Loader.get(name).new(current_user).for(object)
  end

  def not_found(model = 'object')
    render json: { errors: { model => ['not found'] } }, status: :not_found
  end

  def paginate(objects)
    objects.page(params[:page]).per(params[:count])
  end

  def apply_pagination
    objects = instance_variable_get("@#{current_object_plural_name}")
    instance_variable_set("@#{current_object_plural_name}", paginate(objects))
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
    authorize(current_object)
  end

  def respond_to_missing?(method_name, include_private = true)
    method_name == :"#{current_object_singular_name}_params" || super
  end

  def method_missing(method_name, *args, &block)
    if method_name == :"#{current_object_singular_name}_params"
      permitted_attributes(current_object)
    else
      super
    end
  end

  delegate :allowed_to?, to: :current_user, allow_nil: true

  delegate :forbidden_to?, to: :current_user, allow_nil: true

protected

  def current_object
    current_object_singular || current_object_plural || current_model
  end

  def current_object_singular
    instance_variable_get("@#{current_object_singular_name}")
  end

  def current_object_singular=(value)
    instance_variable_set("@#{current_object_singular_name}", value)
  end

  def current_object_plural
    instance_variable_get("@#{current_object_plural_name}")
  end

  def current_object_plural=(value)
    instance_variable_set("@#{current_object_plural_name}", value)
  end

  def current_object_singular_name
    current_model.model_name.singular
  end

  def current_object_plural_name
    current_model.model_name.plural
  end

  def current_model
    @current_model ||= controller_name.singularize.camelize.constantize
  end
end
