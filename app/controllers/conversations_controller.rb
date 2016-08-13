class ConversationsController < ApiController
  include Bannable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_author, except: :create, if: -> {
    params.key? :user_id
  }
  before_action :set_character, except: :create, if: -> {
    params.key? :character_id
  }

  before_action :set_conversations, except: :create
  before_action :set_conversation, except: :index

  before_action :check_locking_permission, only: %i(create update)
  before_action :check_permission, only: :destroy, unless: :admin?

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations.page(params[:page]).per(params[:count]),
           each_serializer: ConversationSerializer,
           meta: {
             page:  params[:page] || 1,
             count: params[:count] || 10,
             total: @conversations.count
           }
  end

  def show
    render json: @conversation
  end

  def create
    @conversation = Conversation.new conversation_params do |conversation|
      conversation.author    = current_user
      conversation.locked_by = current_user if conversation.locked?
    end

    if @conversation.save
      render json: @conversation, status: :created
    else
      errors @conversation
    end
  end

  def update
    if @conversation.update(conversation_params) { |conversation|
         conversation.locked_by = current_user if conversation_params[:locked].present?
       }
      render json: @conversation
    else
      errors @conversation
    end
  end

  def destroy
    if @conversation.update deleted: true
      head :no_content
    else
      errors @conversation
    end
  end

private

  def conversation_params
    params.require(:conversation).permit(
      :locked, first_post_attributes: [ :character_id, :title, :body ]
    )
  end

  def set_conversations
    @conversations = Conversation.includes :author, :first_post, :last_post
    @conversations = @conversations.where author: @author unless @author.nil?
    @conversations = @conversations.where character: @character unless @character.nil?
    @conversations = @conversations.visible unless admin?
  end

  def set_conversation
    @conversation = @conversations.find params[:id]
  end

  def set_author
    @author = User.where id: params[:author_id]
    @author = @author.visible unless admin?
  end

  def set_character
    @character = Character.where id: params[:character_id]
    @character = @character.visible unless admin?
  end

  def check_locking_permissision
    conversation_params.delete :locked unless admin?
  end

  def check_permission
    forbid unless @conversation.author_id == current_user.id
  end

  def increment_views_count
    @conversation.increment! :views_count
  end
end
