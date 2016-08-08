class UsersController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show create)

  before_action :set_users, except: :me
  before_action :set_user, only: %i(show update destroy)
  before_action :confirm_email, only: :update

  def me
    render json: { user: current_user }
  end

  def index
    render json: { users: @users }, each_serializer: UserSerializer
  end

  def show
    render json: { user: @user }
  end

  def create
    @user = User.new user_params

    if @user.save
      render json: { user: @user }, status: :created
    else
      render json: { errors: @user.errors }
    end
  end

  def update
    if @user.update user_params
      render json: { user: @user }
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

  def confirm_email
    @user.touch(:email_confirmed_at) if params[:user][:email_token] == @user.email_token
  end
end
