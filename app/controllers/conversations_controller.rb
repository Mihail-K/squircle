class ConversationsController < ApiController
  before_action :set_conversations, except: :create
  before_action :set_conversation, only: %i(show update destroy)

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations,
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

private

  def set_conversations
    @conversations = Conversation.all.includes :author, :post_authors, :post_characters, :first_post, :last_post
    @conversations = @conversations.where author_id: params[:user_id] if params.key? :user_id
    @conversations = @conversations unless admin?
  end

  def set_conversation
    @conversation = @conversations.find params[:id]
  end

  def increment_views_count
    @conversation.increment! :views_count
  end
end
