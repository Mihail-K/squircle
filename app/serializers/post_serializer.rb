# frozen_string_literal: true
class PostSerializer < ApplicationSerializer
  attribute :id
  attribute :author_id
  attribute :editor_id
  attribute :character_id
  attribute :conversation_id
  attribute :deleted_by_id, if: :allowed_to_view_deleted_posts?

  attribute :display_name
  attribute :character_name
  attribute :body
  attribute :formatted_body
  attribute :likes_count
  attribute :deleted
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_posts?

  attribute :likeable do
    allowed_to?(:create_likes)
  end
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

  has_many :likes, if: :include_likes?

  def include_likes?
    instance_options[:likes].is_a?(Hash)
  end

  def likes
    instance_options[:likes][[object.id, object.class.name]]
  end
end
