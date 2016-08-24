class UsersController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!, except: %i(index show create)

  before_action :set_users, except: %i(me create)
  before_action :set_user, only: %i(show update destroy)
  before_action :apply_pagination, only: :index

  before_action :confirm_email, only: :update

  before_action { policy!(@user || User) }

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
    @user = User.new user_params

    if @user.save
      render json: @user, status: :created
    else
      errors @user
    end
  end

  def update
    if @user.update user_params
      render json: @user
    else
      errors @user
    end
  end

  def destroy
    if @user.update deleted: true
      head :no_content
    else
      errors @user
    end
  end

private

  def user_params
    params.require(:user).permit *policy_params
  end

  def set_users
    @users = policy_scope(User).includes(:characters, :created_characters)
    @users = @users.recently_active if params.key?(:recently_active)
  end

  def set_user
    @user = @users.find params[:id]
  end

  def apply_pagination
    @users = @users.page(params[:page]).per(params[:count])
  end

  def confirm_email
    @user.touch(:email_confirmed_at) if params[:user][:email_token] == @user.email_token
  end
end
