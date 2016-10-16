# frozen_string_literal: true
class PermissionsController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_permissions
  before_action :set_permission, except: :index
  before_action :apply_pagination, only: :index

  def index
    render json: @permissions,
           each_serializer: PermissionSerializer,
           meta: meta_for(@permissions) if stale?(@permissions)
  end

  def show
    render json: @permission,
           serializer: PermissionSerializer if stale?(@permission)
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
