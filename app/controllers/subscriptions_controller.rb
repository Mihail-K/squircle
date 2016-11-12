# frozen_string_literal: true
class SubscriptionsController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_conversation, only: :create

  before_action :set_subscriptions
  before_action :set_subscription, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @subscriptions,
           each_serializer: SubscriptionSerializer,
           meta: meta_for(@subscriptions)
  end

  def show
    render json: @subscription
  end

  def create
    @subscription = Subscription.create!(subscription_params) do |subscription|
      subscription.user = current_user
    end

    render json: @subscription, status: :created
  end

  def destroy
    @subscription.destroy!

    head :no_content
  end

private

  def set_conversation
    return unless subscription_params[:conversation_id].present?
    policy_scope(Conversation).find(subscription_params[:conversation_id])
  end

  def set_subscriptions
    @subscriptions = policy_scope(Subscription).includes(:user, :conversation)
  end

  def set_subscription
    @subscription = @subscriptions.find(params[:id])
  end
end
