# frozen_string_literal: true
class EmailConfirmationSerializer < ApplicationSerializer
  attribute :token
  attribute :user_id
  attribute :status
  attribute :created_at
  attribute :updated_at

  belongs_to :user
end
