class RolesController < ApiController
  before_action :doorkeeper_authorize!

  before_action :set_roles, except: :create
  before_action :set_role, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @roles,
           each_serializer: RoleSerializer,
           meta: meta_for(@roles)
  end

  def show
    render json: @role
  end

  def create
    @role = Role.create!(role_params)

    render json: @role, status: :created
  end

  def update
    @role.update!(role_params)

    render json: @role
  end

  def destroy
    @role.update deleted: true, deleted_by: current_user

    head :no_content
  end

private

  def set_roles
    @roles = policy_scope(Role)
    @roles = @roles.where(user: params[:user_id]) if params.key?(:user_id)
  end

  def set_role
    @role = @roles.find params[:id]
  end

  def apply_pagination
    @roles = @roles.page(params[:page]).per(params[:count])
  end
end
