class UsersController < ApplicationController
  before_action :doorkeeper_authorize!, except: %i(index show create)

  before_action :set_users, except: %i(me create)
  before_action :set_user, only: %i(show update destroy)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def me
    render json: current_user
  end

  def index
    render json: @users,
           each_serializer: UserSerializer,
           meta: meta_for(@users)
  end

  def show
    render json: @user
  end

  def create
    @user = User.create! user_params

    render json: @user, status: :created
  end

  def update
    @user.update! user_params

    render json: @user
  end

  def destroy
    @user.update! deleted: true, deleted_by: current_user

    head :no_content
  end

private

  def set_users
    @users = policy_scope(User)
    @users = @users.recently_active if params.key?(:recently_active)
    @users = @users.most_active if params.key?(:most_active)
    @users = @users.includes(:deleted_by) if can_view_deleted_users?
  end

  def set_user
    @user = @users.find params[:id]
  end

  def apply_pagination
    @users = @users.page(params[:page]).per(params[:count])
  end

  def can_view_deleted_users?
    current_user.try(:allowed_to?, :view_deleted_users)
  end
end
