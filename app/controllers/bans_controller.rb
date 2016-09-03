class BansController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!

  before_action :set_bans, except: :create
  before_action :set_ban, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action { policy!(@ban || Ban) }

  def index
    render json: @bans,
           each_serializer: BanSerializer,
           meta: meta_for(@bans)
  end

  def show
    render json: @ban
  end

  def create
    @ban = Ban.create! ban_params do |ban|
      ban.creator = current_user
    end

    render json: @ban, status: :created
  end

  def update
    @ban.update! ban_params

    render json: @ban
  end

  def destroy
    @ban.update! deleted: true

    head :no_content
  end

private

  def ban_params
    params.require(:ban).permit *policy_params
  end

  def set_bans
    @bans = policy_scope(Ban).includes(:user)
    @bans = @bans.where(user_id: params[:user_id]) if admin? && params.key?(:user_id)
    @bans = @bans.includes(:creator) if admin?
  end

  def set_ban
    @ban = @bans.find params[:id]
  end

  def apply_pagination
    @bans = @bans.page(params[:page]).per(params[:count])
  end
end
