# frozen_string_literal: true
class IndexSerializer < ApplicationSerializer
  attribute :id
  attribute :indexable_id
  attribute :indexable_type

  attribute :created_at
  attribute :updated_at

  belongs_to :indexable, polymorphic: true
end
