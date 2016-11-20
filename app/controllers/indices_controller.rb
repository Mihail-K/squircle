# frozen_string_literal: true
class IndicesController < ApplicationController
  before_action :set_indices

  def index
    render json: @indices,
           each_serializer: IndexSerializer,
           meta: meta_for(@indices)
  end

private

  def set_indices
    @indices = Index.search(query: {
      multi_match: {
        query:  params[:query],
        fields: %w(primary   primary.english^1.5
                   secondary secondary.english^1.5
                   tertiary  tertiary.english^1.5)
      }
    })
    @indices = @indices.page(params[:page]).per(params[:count])
    @indices = @indices.records.includes(:indexable).to_a
  end
end
