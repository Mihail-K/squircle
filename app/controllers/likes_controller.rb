# frozen_string_literal: true
class LikesController < ApplicationController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_likes, except: :create
  before_action :set_like, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @likes,
           each_serializer: LikeSerializer,
           meta: meta_for(@likes)
  end

  def show
    render json: @like
  end

  def create
    @like = Like.create!(like_params) do |like|
      like.user = current_user
    end

    render json: @like, status: :created
  end

  def destroy
    @like.destroy!

    head :no_content
  end

private

  def set_likes
    @likes = policy_scope(Like).includes(:likeable, :user)
    @likes = @likes.where(params.permit(:likeable_id, :likeable_type, :user_id))
  end

  def set_like
    @like = @likes.find(params[:id])
  end
end
