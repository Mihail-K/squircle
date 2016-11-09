# frozen_string_literal: true
class PostSerializer < ApplicationSerializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :editor_id
  attribute :character_id
  attribute :conversation_id
  attribute :deleted_by_id, if: :allowed_to_view_deleted_posts?

  attribute :body
  attribute :formatted_body
  attribute :likes_count
  attribute :deleted
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_posts?

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :author
  belongs_to :editor
  belongs_to :character
  belongs_to :conversation
  belongs_to :deleted_by, if: :allowed_to_view_deleted_posts?
end
