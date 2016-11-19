# frozen_string_literal: true
class IndexJob < ApplicationJob
  queue_as :medium

  def perform(indexable_id, indexable_type)
    index = Index.find_or_initialize_by(indexable_id: indexable_id, indexable_type: indexable_type)
    index.populate if index.persisted?
    index.save
  end
end
