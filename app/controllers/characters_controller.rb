class CharactersController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_characters, except: :create
  before_action :set_character, only: %i(show update destroy)

  before_action :check_permission, only: %i(update destroy), unless: :admin?

  def index
    render json: @characters.page(params[:page]).per(params[:count].to_i || 10),
           each_serializer: CharacterSerializer,
           meta: {
             page:  params[:page] || 1,
             count: params[:count] || 10,
             total: @characters.count
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
      :name, :title, :description
    )
  end

  def set_characters
    @characters = Character.all
    @characters = @characters.visible if current_admin.nil?
    @characters = @characters.where user_id: params[:user_id] if params.key? :user_id
    @characters = @characters.includes :user, :creator, :posts
  end

  def set_character
    @character = @characters.find params[:id]
  end

  def check_permission
    forbid unless @character.user_id == current_user.id
  end
end
