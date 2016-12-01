# frozen_string_literal: true
class PasswordResetSerializer < ActiveModel::Serializer
  attribute :token
  attribute :status
  attribute :created_at
  attribute :updated_at
end
