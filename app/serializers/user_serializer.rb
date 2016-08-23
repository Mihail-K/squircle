class UserSerializer < ActiveModel::Serializer
  cache expires_in: 3.hours

  attribute :id
  attribute :display_name
  attribute :created_at
  attribute :last_active_at

  attribute :email, if: :can_view_email?
  attribute :email_confirmed_at, if: :can_view_email?

  attribute :first_name, if: :can_view_personal_data?
  attribute :last_name, if: :can_view_personal_data?
  attribute :date_of_birth, if: :can_view_personal_data?

  attribute :characters_count
  attribute :created_characters_count
  attribute :posts_count do
    # Unless the viewer is an admin, show only visible post count.
    current_user.try(:admin?) ? object.posts_count : object.visible_posts_count
  end

  attribute :admin
  attribute :banned

  attribute :avatar_url do
    url = object.avatar.url
    url = 'http://localhost:3000' + url if url && Rails.env.development?
    url
  end
  attribute :avatar_medium_url do
    url = object.avatar.medium.url
    url = 'http://localhost:3000' + url if url && Rails.env.development?
    url
  end
  attribute :avatar_thumb_url do
    url = object.avatar.thumb.url
    url = 'http://localhost:3000' + url if url && Rails.env.development?
    url
  end

  def can_view_email?
    object.id == current_user.try(:id) ||
    current_user.try(:admin?)
  end

  def can_view_personal_data?
    object.id == current_user.try(:id) ||
    current_user.try(:admin?)
  end
end
