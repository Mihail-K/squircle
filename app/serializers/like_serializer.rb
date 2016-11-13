# frozen_string_literal: true
class LikeSerializer < ApplicationSerializer
  attribute :id
  attribute :user_id
  attribute :likeable_id
  attribute :likeable_type

  attribute :created_at
  attribute :updated_at

  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :user
  belongs_to :likeable, polymorphic: true
end
