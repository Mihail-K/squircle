class UsersController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show create)

  before_action :set_users, except: %i(me create)
  before_action :set_user, only: %i(show update destroy)
  before_action :check_current_user, only: :create
  before_action :check_permission, only: %i(update destroy)
  before_action :confirm_email, only: :update

  def me
    render json: current_user
  end

  def index
    render json: @users, each_serializer: UserSerializer
  end

  def show
    render json: @user
  end

  def create
    @user = User.new user_params

    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors }
    end
  end

  def update
    if @user.update user_params
      render json: @user
    else
      render json: { errors: @user.errors }
    end
  end

  def destroy
    if @user.destroy
      head :no_content
    else
      render json: { errors: @user.errors }
    end
  end

private

  def user_params
    params.require(:user).permit(
      :email, :display_name, :first_name, :last_name, :date_of_birth,
      :password, :password_confirmation
    )
  end

  def set_users
    @users = User.all
  end

  def set_user
    @user = @users.find params[:id]
  end

  def check_current_user
    forbid unless current_user.blank? || current_user.try(:admin?)
  end

  def check_permission
    forbid unless @user.id == current_user.id || current_user.admin?
  end

  def confirm_email
    @user.touch(:email_confirmed_at) if params[:user][:email_token] == @user.email_token
  end
end
