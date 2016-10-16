# frozen_string_literal: true
class PermissionSerializer < ActiveModel::Serializer
  type :permission

  attribute :id
  attribute :name
  attribute :description
end
