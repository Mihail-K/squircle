# frozen_string_literal: true
class SectionSerializer < ApplicationSerializer
  attribute :id
  attribute :parent_id
  attribute :creator_id, if: :allowed_to_create_sections?
  attribute :deleted_by_id, if: :allowed_to_view_deleted_sections?

  attribute :title
  attribute :description
  # attribute :logo_url, if: -> { object.logo.file.present? } do
  #   object.logo.url
  # endr
  attribute :conversations_count
  attribute :posts_count
  attribute :deleted

  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_sections?

  attribute :postable do
    allowed_to?(:create_conversations)
  end
  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :creator, if: :allowed_to_create_sections?
  belongs_to :deleted_by, if: :allowed_to_view_deleted_sections?
end
