# frozen_string_literal: true
class SubscriptionSerializer < ActiveModel::Serializer
  attribute :id
  attribute :user_id
  attribute :conversation_id

  attribute :created_at
  attribute :updated_at

  belongs_to :user
  belongs_to :conversation
end
