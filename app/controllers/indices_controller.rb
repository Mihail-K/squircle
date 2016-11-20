# frozen_string_literal: true
class IndicesController < ApplicationController
  before_action :set_indices
  before_action :apply_pagination

  def index
    render json: @indices,
           each_serializer: IndexSerializer,
           meta: meta_for(@indices)
  end

private

  def set_indices
    @indices = policy_scope(Index).includes(:indexable)
    @indices = @indices.where(params.permit(:indexable_type))
  end
end
