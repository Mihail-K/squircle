class UsersController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show create)

  before_action :set_users, except: %i(me create)
  before_action :set_user, only: %i(show update destroy)

  before_action :check_current_user, only: :create, unless: :admin?
  before_action :check_permission, only: %i(update destroy), unless: :admin?

  before_action :confirm_email, only: :update

  def me
    render json: current_user
  end

  def index
    render json: @users.page(params[:page]).per(params[:count].to_i || 10),
           each_serializer: UserSerializer,
           meta: {
             page:  params[:page] || 1,
             count: params[:count] || 10,
             total: @users.count
           }
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
    params.require(:user).permit(
      :email, :display_name, :first_name, :last_name, :date_of_birth,
      :password, :password_confirmation,
      :avatar
    )
  end

  def set_users
    @users = User.all.includes :characters, :created_characters
    @users = @users.visible unless admin?
  end

  def set_user
    @user = @users.find params[:id]
  rescue ActiveRecord::RecordNotFound
    not_found :user
  end

  def check_current_user
    forbid unless current_user.blank?
  end

  def check_permission
    forbid unless @user.id == current_user.id
  end

  def confirm_email
    @user.touch(:email_confirmed_at) if params[:user][:email_token] == @user.email_token
  end
end
