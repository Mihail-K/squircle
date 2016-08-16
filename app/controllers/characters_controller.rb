class CharactersController < ApiController
  include Bannable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_user, except: :create, if: -> {
    params.key? :user_id
  }

  before_action :set_characters, except: :create
  before_action :set_character, only: %i(show update destroy)

  before_action :apply_pagination, only: :index

  before_action :check_permission, only: %i(update destroy), unless: :admin?

  def index
    render json: @characters,
           each_serializer: CharacterSerializer,
           meta: {
             page:  @characters.current_page,
             count: @characters.limit_value,
             total: @characters.total_count,
             pages: @characters.total_pages
           }
  end

  def show
    render json: @character
  end

  def create
    @character = Character.new character_params do |character|
      character.user_id = current_user
    end

    if @character.save
      render json: @character, status: :created
    else
      errors @character
    end
  end

  def update
    if @character.update character_params
      render json: @character
    else
      errors @character
    end
  end

  def destroy
    if @character.update deleted: true
      head :no_content
    else
      errors @character
    end
  end

private

  def character_params
    params.require(:character).permit(
      :name, :title, :description, :avatar, gallery_images: [ ]
    )
  end

  def set_user
    @user = User.where id: params[:user_id]
    @user = @user.visible unless admin?
  end

  def set_characters
    @characters = Character.includes :user, :creator
    @characters = @characters.where user: @user unless @user.nil?
    @characters = @characters.visible unless admin?
  end

  def apply_pagination
    @characters = @characters.page(params[:page]).per(params[:count])
  end

  def set_character
    @character = @characters.find params[:id]
  end

  def check_permission
    forbid unless @character.user_id == current_user.id
  end
end
