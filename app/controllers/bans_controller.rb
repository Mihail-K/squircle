class BansController < ApiController
  before_action :doorkeeper_authorize!

  before_action :set_bans, except: :create
  before_action :set_ban, except: %i(index create)

  before_action :apply_pagination, only: :index

  before_action :check_permission, only: %i(create update destroy)

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
    if @ban.destroy
      head :no_content
    else
      errors @ban
    end
  end

private

  def ban_params
    params.require(:ban).permit :reason, :expires_at, :user_id
  end

  def set_bans
    @bans = Ban.all
    @bans = @bans.where user_id: current_user.id unless admin?
  end

  def apply_pagination
    @bans = @bans.page(params[:page]).per(params[:count])
  end

  def set_ban
    @ban = @bans.find params[:id]
  end

  def check_permission
    forbid unless admin?
  end
end
