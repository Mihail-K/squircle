# frozen_string_literal: true
class IndexJob < ApplicationJob
  queue_as :medium

  def perform(indexable_id, indexable_type)
    Index.where(indexable_id: indexable_id, indexable_type: indexable_type)
         .first_or_initialize
         .save
  end
end
