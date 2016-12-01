# frozen_string_literal: true
class IndicesController < ApplicationController
  before_action :set_indices
  before_action :set_records

  def index
    render json: @records.includes(:indexable).to_a,
           each_serializer: IndexSerializer,
           meta: meta_for(@records)
  end

private

  def set_indices
    @indices = Index.search(QueryBuilder.new(params).build)
    @indices.search.definition[:preference] = request.remote_ip
    @indices = @indices.page(params[:page]).per(params[:count])
  end

  def set_records
    @records = @indices.records
  end
end
