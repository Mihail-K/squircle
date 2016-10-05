class PermissionsController < ApiController
  before_action :doorkeeper_authorize!

  before_action :set_permissions
  before_action :set_permission, except: :index
  before_action :apply_pagination, only: :index

  def index
    render json: @permissions,
           each_serializer: PermissionSerializer,
           meta: meta_for(@permissions)
  end

  def show
    render json: @permission,
           serializer: PermissionSerializer
  end

private

  def set_permissions
    @permissions = Permissible::Permission.all
  end

  def set_permission
    @permission = @permissions.find params[:id]
  end

  def apply_pagination
    @permissions = @permissions.page(params[:page]).per(params[:count])
  end
end
