# frozen_string_literal: true
class UserSerializer < ApplicationSerializer
  cache expires_in: 3.hours

  attribute :id
  attribute :deleted_by_id, if: :can_view_deleted_users?

  attribute :display_name
  attribute :created_at
  attribute :last_active_at

  attribute :email, if: :can_view_users_personal_fields?
  attribute :email_confirmed_at, if: :can_view_users_personal_fields?

  attribute :first_name, if: :can_view_users_personal_fields?
  attribute :last_name, if: :can_view_users_personal_fields?
  attribute :date_of_birth, if: :can_view_users_personal_fields?

  attribute :characters_count
  attribute :created_characters_count
  attribute :posts_count

  attribute :banned
  attribute :deleted

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  attribute :avatar_url, if: -> { object.avatar.file.present? } do
    object.avatar.url
  end
  attribute :avatar_medium_url, if: -> { object.avatar.medium.file.present? } do
    object.avatar.medium.url
  end
  attribute :avatar_thumb_url, if: -> { object.avatar.thumb.file.present? } do
    object.avatar.thumb.url
  end

  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_users?

  def can_view_users_personal_fields?
    object.id == current_user.try(:id) || allowed_to?(:view_users_personal_fields)
  end

  def can_view_deleted_users?
    allowed_to?(:view_deleted_users)
  end
end
