# frozen_string_literal: true
class ConversationsController < ApplicationController
  include FloodLimitable

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_character, only: :create
  before_action :set_section, only: :create

  before_action :set_conversations, except: :create
  before_action :set_conversation, except: %i(index create)
  before_action :apply_pagination, only: :index
  before_action :enforce_policy!

  after_action :increment_views_count, only: :show

  def index
    render json: @conversations,
           each_serializer: ConversationSerializer,
           participation: load(:participation, @conversations),
           subscriptions: load(:subscription, @conversations),
           meta: meta_for(@conversations)
  end

  def show
    render json: @conversation,
           participation: load(:participation, @conversation),
           subscriptions: load(:subscription, @conversation)
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

    render json: @conversation,
           participation: load(:participation, @conversation),
           subscriptions: load(:subscription, @conversation)
  end

  def destroy
    @conversation.soft_delete! do |conversation|
      conversation.deleted_by = current_user
    end

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

  def set_section
    return unless conversation_params[:section_id].present?
    policy_scope(Section).find(conversation_params[:section_id])
  end

  def set_conversations
    @conversations = policy_scope(Conversation).order(last_active_at: :desc)
    @conversations = @conversations.includes(:author, :section, :first_post, :last_post)
    @conversations = @conversations.includes(:deleted_by) if allowed_to?(:view_deleted_conversations)
    @conversations = @conversations.where(params.permit(:author_id, :character_id, :section_id))
    @conversations = @conversations.recently_active if params.key?(:recently_active)
  end

  def set_conversation
    @conversation = @conversations.find(params[:id])
  end

  def increment_views_count
    @conversation.increment!(:views_count)
  end
end
