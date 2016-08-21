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
           meta: {
             page:  @bans.current_page,
             count: @bans.limit_value,
             total: @bans.total_count,
             pages: @bans.total_pages
           }
  end

  def show
    render json: @ban
  end

  def create
    @ban = Ban.new ban_params do |ban|
      ban.creator = current_user
    end

    if @ban.save
      render json: @ban, status: :created
    else
      errors @ban
    end
  end

  def update
    if @ban.update ban_params
      render json: @ban
    else
      errors @ban
    end
  end

  def destroy
    if @ban.update deleted: true
      head :no_content
    else
      errors @ban
    end
  end

private

  def ban_params
    params.require(:ban).permit *policy_params
  end

  def set_bans
    @bans = policy_scope
  end

  def set_ban
    @ban = @bans.find params[:id]
  end

  def apply_pagination
    @bans = @bans.page(params[:page]).per(params[:count])
  end
end
