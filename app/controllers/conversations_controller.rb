# frozen_string_literal: true
class ConversationsController < ApplicationController
  include FloodLimitable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_character, only: :create

  before_action :set_conversations, except: :create
  before_action :set_conversation, except: %i(index create)
  before_action :apply_pagination, only: :index
  before_action :enforce_policy!

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations,
           each_serializer: ConversationSerializer,
           participation: participation,
           subscriptions: subscriptions,
           meta: meta_for(@conversations)
  end

  def show
    render json: @conversation,
           participation: participation,
           subscriptions: subscriptions
  end

  def create
    @conversation = Conversation.create!(conversation_params) do |conversation|
      conversation.author    = current_user
      conversation.locked_by = current_user if conversation.locked?
    end

    render json: @conversation, status: :created
  end

  def update
    @conversation.attributes = conversation_params
    @conversation.locked_by  = current_user if @conversation.locked_changed?(to: true)
    @conversation.save!

    render json: @conversation
  end

  def destroy
    @conversation.soft_delete!(current_user)

    head :no_content
  end

private

  def character_id
    conversation_params[:posts_attributes].present? &&
      conversation_params[:posts_attributes].first.present? &&
      conversation_params[:posts_attributes].first[:character_id]
  end

  def set_character
    policy_scope(Character).where(user: current_user).find(character_id) if character_id.present?
  end

  def set_conversations
    @conversations = policy_scope(Conversation).order(last_active_at: :desc)
    @conversations = @conversations.includes(:author, :section, first_post: :conversation, last_post: :conversation)
    @conversations = @conversations.includes(:deleted_by) if allowed_to?(:view_deleted_conversations)
    @conversations = @conversations.where(params.permit(:author_id, :character_id, :section_id))
    @conversations = @conversations.recently_active if params.key?(:recently_active)
  end

  def apply_pagination
    @conversations = @conversations.page(params[:page]).per(params[:count])
  end

  def set_conversation
    @conversation = @conversations.find(params[:id])
  end

  def increment_views_count
    @conversation.increment!(:views_count)
  end

  def participation
    return if current_user.nil?
    # A Hash of the current user's participation in conversations.
    policy_scope(Post).group(Post.arel_table[:conversation_id])
                      .where(posts: { author_id: current_user })
                      .where(conversation_id: @conversation || @conversations)
                      .count
  end

  def subscriptions
    return if current_user.nil?
    # A Hash of the current user's subscriptions to conversations.
    Subscription.where(user: current_user, conversation: @conversation || @conversations)
                .group_by(&:conversation_id)
  end
end
