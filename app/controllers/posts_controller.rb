class PostsController < ApiController
  include Bannable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_author, except: :create, if: -> {
    params.key?(:user_id) || params.key?(:author_id)
  }
  before_action :set_character, except: :create, if: -> {
    params.key? :character_id
  }
  before_action :set_conversation, except: :create, if: -> {
    params.key? :conversation_id
  }

  before_action :set_posts, except: :create
  before_action :set_post, except: %i(index create)

  before_action :check_lock_state, only: %i(create update destroy), unless: :admin?
  before_action :check_permission, only: %i(update destroy), unless: :admin?
  before_action :check_flood_limit, only: :create, unless: :admin?

  def index
    render json: @posts.page(params[:page]).per(params[:count] || 10),
           each_serializer: PostSerializer,
           meta: {
             page:  params[:page] || 1,
             count: params[:count] || 10,
             total: @posts.count
           }
  end

  def show
    render json: @post
  end

  def create
    @post = Post.new post_params do |post|
      post.author = current_user
    end

    if @post.save
      render json: @post, status: :created
    else
      errors @post
    end
  end

  def update
    if @post.update(post_params) { |post| post.editor = current_user }
      render json: @post
    else
      errors @post
    end
  end

  def destroy
    if @post.update deleted: true
      head :no_content
    else
      errors @post
    end
  end

private

  def post_params
    params.require(:post).permit :conversation_id, :character_id, :title, :body
  end

  def set_posts
    @posts = Post.includes :author, :editor, :character, :conversation
    @posts = @posts.where author: @author unless @author.nil?
    @posts = @posts.where character: @character unless @character.nil?
    @posts = @posts.where conversation: @conversation unless @conversation.nil?
    @posts = @posts.visible unless admin?
  end

  def set_post
    @post = @posts.find params[:id]
  end

  def set_author
    @author = User.where id: params[:user_id] || params[:author_id]
    @author = @author.visible unless admin?
  end

  def set_character
    @character = Character.where id: params[:character_id]
    @character = @character.visible unless admin?
  end

  def set_conversation
    @conversation = Conversation.where id: params[:conversation_id]
    @conversation = @conversation.visible unless admin?
  end

  def check_lock_state
    if action_name == 'create'
      forbid if Conversation.locked.exists? id: post_params[:conversation_id]
    else
      forbid if @post.locked?
    end
  end

  def check_permission
    forbid unless @post.author_id == current_user.id
  end

  def check_flood_limit
    if Post.where(author_id: current_user).where('created_at > ?', 20.seconds.ago).exists?
      @post.errors.add :base, 'you can only post once every 20 seconds'
      errors @post
    end
  end
end
