class PostsController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_posts, except: :create
  before_action :set_post, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :check_flood_limit, only: :create, unless: :admin?

  before_action { policy!(@post || Post) }

  def index
    render json: @posts,
           each_serializer: PostSerializer,
           meta: meta_for(@posts)
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
    @post.editor = current_user
    if @post.update post_params
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
    params.require(:post).permit *policy_params
  end

  def set_posts
    @posts = policy_scope(Post).includes(:author, :editor, :character, :conversation)
    @posts = @posts.where(author: params[:user_id] || params[:author_id]) if params.key?(:user_id) || params.key?(:author_id)
    @posts = @posts.where(character: params[:character_id]) if params.key?(:character_id)
    @posts = @posts.where(conversation: params[:conversation_id]) if params.key?(:conversation_id)
    @posts = @posts.order(created_at: :asc)
  end

  def apply_pagination
    @posts = @posts.page(params[:page]).per(params[:count])
  end

  def set_post
    @post = @posts.find params[:id]
  end

  def check_flood_limit
    if Post.where(author_id: current_user)
           .where(Post.arel_table[:created_at].gteq(20.seconds.ago))
           .exists?
      @post = Post.new
      @post.errors.add :base, 'you can only post once every 20 seconds'
      errors @post
    end
  end
end
