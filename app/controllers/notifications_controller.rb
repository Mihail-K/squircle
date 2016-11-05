# frozen_string_literal: true
class NotificationsController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_notifications
  before_action :set_notification, except: :index
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  after_action :mark_notifications_read, only: :index, if: -> { params.key?(:read) }

  def index
    render json: @notifications,
           each_serializer: NotificationSerializer,
           meta: meta_for(@notifications)
  end

  def show
    render json: @notification
  end

  def update
    @notification.update!(notification_params)

    render json: @notification
  end

  def destroy
    @notification.destroy!

    head :no_content
  end

private

  def set_notifications
    @notifications = policy_scope(Notification).includes(:user, :targetable)
    @notifications = @notifications.pending if params.key?(:pending)
  end

  def set_notification
    @notification = @notifications.find(params[:id])
  end

  def apply_pagination
    @notifications = @notifications.page(params[:page]).per(params[:count])
  end

  def mark_notifications_read
    Notification.where(id: @notifications).update_all(read: true)
  end
end
