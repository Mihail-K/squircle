# frozen_string_literal: true
class RolesController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_roles, except: :create
  before_action :set_role, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @roles,
           each_serializer: RoleSerializer,
           meta: meta_for(@roles) if stale?(@roles)
  end

  def show
    render json: @role if stale?(@role)
  end

  def create
    @role = @roles.create!(role_params)

    render json: @role, status: :created
  end

  def update
    @role.update!(role_params)

    render json: @role
  end

  def destroy
    @role.soft_delete! do |role|
      role.deleted_by = current_user
    end

    head :no_content
  end

private

  def set_roles
    @roles = policy_scope(Role)
    @roles = @roles.includes(:deleted_by) if allowed_to?(:view_deleted_roles)
  end

  def set_role
    @role = @roles.find params[:id]
  end
end
