# frozen_string_literal: true
class PostsController < ApplicationController
  include FloodLimitable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_conversation, only: :create
  before_action :set_character, only: %i(create update)

  before_action :set_posts, except: :create
  before_action :set_post, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @posts,
           likes: load(:like, @posts),
           meta: meta_for(@posts)
  end

  def show
    render json: @post, likes: preview_likes
  end

  def create
    @post = Post.create!(post_params) do |post|
      post.author       = current_user
      post.conversation = @conversation
    end

    render json: @post, status: :created
  end

  def update
    @post.attributes = post_params
    @post.editor = current_user if @post.body_changed? unless post_params.key?(:editor_id)
    @post.save!

    render json: @post, likes: preview_likes
  end

  def destroy
    @post.soft_delete! do |post|
      post.deleted_by = current_user
    end

    head :no_content
  end

private

  def set_conversation
    @conversation = policy_scope(Conversation).find(post_params[:conversation_id])
    forbid if @conversation.locked? unless allowed_to?(:lock_conversations)
  end

  def set_character
    return unless post_params[:character_id].present?
    policy_scope(Character).where(user: current_user).find(post_params[:character_id])
  end

  def set_posts
    @posts = policy_scope(Post).includes(:author, :editor, :character, :conversation)
    @posts = @posts.includes(:deleted_by) if allowed_to?(:view_deleted_posts)
    @posts = @posts.where(params.permit(:user_id, :author_id, :character_id, :conversation_id))
    @posts = @posts.order(created_at: :asc)
  end

  def set_post
    @post = @posts.find(params[:id])
  end

  def preview_likes
    policy_scope(Like).where(likeable: @post || @posts).preview
                      .group_by { |like| [like.likeable_id, like.likeable_type] }
  end
end
