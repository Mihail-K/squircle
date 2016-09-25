class BansController < ApiController
  before_action :doorkeeper_authorize!

  before_action :set_bans, except: :create
  before_action :set_ban, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

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
    @ban.update! deleted: true, deleted_by: current_user

    head :no_content
  end

private

  def set_bans
    @bans = policy_scope(Ban).includes(:user)
    @bans = @bans.where(user: params[:user_id]) if can_view_bans? && params.key?(:user_id)
    @bans = @bans.includes(:creator) if can_view_ban_creator?
    @bans = @bans.includes(:deleted_by) if can_view_deleted_bans?
  end

  def set_ban
    @ban = @bans.find params[:id]
  end

  def apply_pagination
    @bans = @bans.page(params[:page]).per(params[:count])
  end

  def can_view_bans?
    current_user.try(:allowed_to?, :view_bans)
  end

  def can_view_ban_creator?
    current_user.try(:allowed_to?, :view_ban_creator)
  end

  def can_view_deleted_bans?
    current_user.try(:allowed_to?, :view_deleted_bans)
  end
end
