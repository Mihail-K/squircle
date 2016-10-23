# frozen_string_literal: true
class FriendshipsController < ApplicationController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_friendships
  before_action :set_friendship, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @friendships,
           each_serializer: FriendshipSerializer,
           meta: meta_for(@friendships)
  end

  def show
    render json: @friendship
  end

  def create
    @friendship = @friendships.create!(friendship_params) do |friendship|
      friendship.user = current_user
    end

    render json: @friendship, status: :created
  end

  def destroy
    @friendship.destroy!

    head :no_content
  end

private

  def set_friendships
    @friendships = policy_scope(Friendship).includes(:user, :friend)
    @friendships = @friendships.where(params.permit(:user_id, :friend_id))
  end

  def set_friendship
    @friendship = @friendships.find(params[:id])
  end

  def apply_pagination
    @friendships = @friendships.page(params[:page]).per(params[:count])
  end
end
