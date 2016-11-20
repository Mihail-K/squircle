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
    @indices = Index.search(query: {
      multi_match: {
        query:  params[:query],
        fields: %w(primary   primary.english^2   primary.raw^3
                   secondary secondary.english^2 secondary.raw^3
                   tertiary  tertiary.english^2  tertiary.raw^3)
      }
    })
  end
end
