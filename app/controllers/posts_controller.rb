class PostsController < ApplicationController
  include FloodLimitable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_conversation, only: :create

  before_action :set_posts, except: :create
  before_action :set_post, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @posts,
           each_serializer: PostSerializer,
           meta: meta_for(@posts)
  end

  def show
    render json: @post
  end

  def create
    @post = Post.create! post_params do |post|
      post.author = current_user
    end

    render json: @post, status: :created
  end

  def update
    @post.editor = current_user
    @post.update! post_params

    render json: @post
  end

  def destroy
    @post.update! deleted: true, deleted_by: current_user

    head :no_content
  end

private

  def set_conversation
    @conversation = policy_scope(Conversation).find(params[:conversation_id] || post_params[:conversation_id])
    forbid if @conversation.locked? unless can_lock_conversations?
  end

  def set_posts
    @posts = policy_scope(Post).includes(:author, :editor, :character, :conversation)
    @posts = @posts.where(author: params[:user_id] || params[:author_id]) if params.key?(:user_id) || params.key?(:author_id)
    @posts = @posts.where(character: params[:character_id]) if params.key?(:character_id)
    @posts = @posts.where(conversation: params[:conversation_id]) if params.key?(:conversation_id)
    @posts = @posts.order(created_at: :asc)
    @posts = @posts.includes(:deleted_by) if can_view_deleted_posts?
  end

  def apply_pagination
    @posts = @posts.page(params[:page]).per(params[:count])
  end

  def set_post
    @post = @posts.find params[:id]
  end

  def can_lock_conversations?
    current_user.try(:allowed_to?, :lock_conversations)
  end

  def can_view_deleted_posts?
    current_user.try(:allowed_to?, :view_deleted_posts)
  end
end
