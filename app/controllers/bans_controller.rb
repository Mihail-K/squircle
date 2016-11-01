# frozen_string_literal: true
class BansController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_bans
  before_action :set_ban, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @bans,
           each_serializer: BanSerializer,
           meta: meta_for(@bans) if stale?(@bans)
  end

  def show
    render json: @ban if stale?(@ban)
  end

  def create
    @ban = @bans.create!(ban_params) do |ban|
      ban.creator = current_user
    end

    render json: @ban, status: :created
  end

  def update
    @ban.update!(ban_params)

    render json: @ban
  end

  def destroy
    @ban.soft_delete!(current_user)

    head :no_content
  end

private

  def set_bans
    @bans = policy_scope(Ban).includes(:user)
    @bans = @bans.where(user_id: params[:user_id]) if allowed_to?(:view_bans) && params.key?(:user_id)
    @bans = @bans.includes(:creator) if allowed_to?(:view_ban_creator)
    @bans = @bans.includes(:deleted_by) if allowed_to?(:view_deleted_bans)
  end

  def set_ban
    @ban = @bans.find(params[:id])
  end

  def apply_pagination
    @bans = @bans.page(params[:page]).per(params[:count])
  end
end
