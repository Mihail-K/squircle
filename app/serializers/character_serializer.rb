# frozen_string_literal: true
class CharacterSerializer < ApplicationSerializer
  attribute :id
  attribute :user_id
  attribute :creator_id
  attribute :deleted_by_id, if: :allowed_to_view_deleted_characters?

  attribute :name
  attribute :title
  attribute :description
  attribute :posts_count
  attribute :deleted

  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_characters?

  attribute :avatar_url do
    object.avatar.url
  end
  attribute :gallery_image_urls do
    object.gallery_images.map(&:url)
  end

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :user
  belongs_to :creator
  belongs_to :deleted_by, if: :allowed_to_view_deleted_characters?
end
