class CharactersController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_user, except: :create, if: -> {
    params.key? :user_id
  }

  before_action :set_characters, except: :create
  before_action :set_character, only: %i(show update destroy)
  before_action :apply_pagination, only: :index

  before_action { policy!(@character || Character) }

  def index
    render json: @characters,
           each_serializer: CharacterSerializer,
           meta: meta_for(@characters)
  end

  def show
    render json: @character
  end

  def create
    @character = Character.create! character_params do |character|
      character.user = current_user
    end

    render json: @character, status: :created
  end

  def update
    @character.update! character_params

    render json: @character
  end

  def destroy
    @character.update! deleted: true

    head :no_content
  end

private

  def character_params
    params.require(:character).permit *policy_params
  end

  def set_user
    @user = policy_scope(User).where(id: params[:user_id])
  end

  def set_characters
    @characters = policy_scope(Character).includes(:user, :creator)
    @characters = @characters.where(user: @user) unless @user.nil?
  end

  def apply_pagination
    @characters = @characters.page(params[:page]).per(params[:count])
  end

  def set_character
    @character = @characters.find params[:id]
  end
end
