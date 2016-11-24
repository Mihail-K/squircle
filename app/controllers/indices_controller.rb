# frozen_string_literal: true
class IndicesController < ApplicationController
  before_action :set_indices

  def index
    render json: @indices.includes(:indexable).to_a,
           each_serializer: IndexSerializer,
           meta: meta_for(@indices)
  end

private

  def set_indices
    @indices = Index.search(QueryBuilder.new(params).build)
    @indices = @indices.page(params[:page]).per(params[:count])
    @indices = @indices.records
  end
end
