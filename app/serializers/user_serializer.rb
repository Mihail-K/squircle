# frozen_string_literal: true
class UserSerializer < ApplicationSerializer
  attribute :id
  attribute :deleted_by_id, if: :allowed_to_view_deleted_users?

  attribute :display_name
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_users?
  attribute :last_active_at

  attribute :email, if: :allowed_to_view_users_personal_fields?
  attribute :email_confirmed_at, if: :allowed_to_view_users_personal_fields?

  attribute :first_name, if: :allowed_to_view_users_personal_fields?
  attribute :last_name, if: :allowed_to_view_users_personal_fields?
  attribute :date_of_birth, if: :allowed_to_view_users_personal_fields?

  attribute :characters_count
  attribute :created_characters_count
  attribute :posts_count

  attribute :banned
  attribute :deleted

  attribute :friendshipable do
    current_user.present?
  end
  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  attribute :avatar_url do
    object.avatar.url
  end
  attribute :avatar_medium_url do
    object.avatar.medium.url
  end
  attribute :avatar_thumb_url do
    object.avatar.thumb.url
  end

  belongs_to :deleted_by, if: :allowed_to_view_deleted_users?

  has_one :friendship, if: :include_friendships?

  def allowed_to_view_users_personal_fields?
    object.id == current_user&.id || allowed_to?(:view_users_personal_fields)
  end

  def include_friendships?
    instance_options[:friendships].is_a?(Hash)
  end

  def friendship
    instance_options[:friendships][object.id]
  end
end
