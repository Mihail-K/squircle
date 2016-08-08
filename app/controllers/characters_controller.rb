class CharactersController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_characters
  before_action :set_character, only: %i(show update destroy)

  def index
    render json: @characters, each_serializer: CharacterSerializer
  end

  def show
    render json: @character
  end

  def create
    @character = @characters.new character_params

    if @character.save
      render json: @character, status: :created
    else
      render json: { errors: @character.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @character.update character_params
      render json: @character
    else
      render json: { errors: @character.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @character.destroy
      head :no_content
    else
      render json: { errors: @character.errors }
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
  end

  def set_character
    @character = @characters.find params[:id]
  end
end
