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
  before_action :set_conversation, except: %i(index create)

  before_action :apply_pagination, only: :index
  before_action :load_first_posts, only: :index

  before_action :check_permission, only: %i(update destroy), unless: :admin?

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations,
           each_serializer: ConversationSerializer,
           first_posts: @first_posts,
           meta: {
             page:  @conversations.current_page,
             count: @conversations.limit_value,
             total: @conversations.total_count,
             pages: @conversations.total_pages
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
    if conversation_params[:locked].present?
      @conversation.locked_by = current_user
    end

    if @conversation.update conversation_params
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
    params.require(:conversation).permit *permitted_params
  end

  def permitted_params
    permitted  = [ posts_attributes: %i(character_id title body) ]
    permitted << :locked if admin?
    permitted
  end

  def set_author
    @author = User.where id: params[:author_id]
    @author = @author.visible unless admin?
  end

  def set_character
    @character = Character.where id: params[:character_id]
    @character = @character.visible unless admin?
  end

  def set_conversations
    @conversations = Conversation.includes :author
    @conversations = @conversations.where author: @author unless @author.nil?
    @conversations = @conversations.where character: @character unless @character.nil?
    @conversations = @conversations.visible unless admin?
  end

  def apply_pagination
    @conversations = @conversations.page(params[:page]).per(params[:count])
  end

  def load_first_posts
    # Load a list of first posts for the list of conversations.
    @first_posts = Post.first_posts.where conversation: @conversations
    @first_posts = @first_posts.visible unless admin?

    # Re-map the first posts to a Hash keyed by the posts' conversation ids.
    @first_posts = @first_posts.map { |post| [ post.conversation_id, post ] }.to_h
  end

  def set_conversation
    @conversation = @conversations.find params[:id]
  end

  def check_permission
    forbid unless @conversation.author_id == current_user.id
  end

  def increment_views_count
    @conversation.increment! :views_count
  end
end
