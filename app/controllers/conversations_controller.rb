class ConversationsController < ApiController
  include Political::Authority

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
  before_action :load_participated, only: :index, if: -> { current_user.present? }

  before_action { policy!(@conversation || Conversation) }

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations,
           each_serializer: ConversationSerializer,
           first_posts: @first_posts,
           participated: @participated,
           meta: meta_for(@conversations)
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
    params.require(:conversation).permit *policy_params
  end

  def set_author
    @author = policy_scope(User).where id: params[:author_id]
  end

  def set_character
    @character = policy_scope(Character).where id: params[:character_id]
  end

  def set_conversations
    @conversations = policy_scope(Conversation).includes(:author)
    @conversations = @conversations.where(author: @author) unless @author.nil?
    @conversations = @conversations.where(character: @character) unless @character.nil?
  end

  def apply_pagination
    @conversations = @conversations.page(params[:page]).per(params[:count])
  end

  def load_first_posts
    # Load a list of first posts for the list of conversations.
    @first_posts = policy_scope(Post).first_posts.where conversation: @conversations

    # Re-map the first posts to a Hash keyed by the posts' conversation ids.
    @first_posts = @first_posts.map { |post| [ post.conversation_id, post ] }.to_h
  end

  def load_participated
    # Construct a hash containing the current user's participation in conversations.
    @participated = policy_scope(Post).joins(:conversation)
                                      .group(Post.arel_table[:conversation_id])
                                      .where(posts: { author_id: current_user })
                                      .where(conversations: { id: @conversations })
                                      .count
  end

  def set_conversation
    @conversation = @conversations.find params[:id]
  end

  def increment_views_count
    @conversation.increment! :views_count
  end
end
