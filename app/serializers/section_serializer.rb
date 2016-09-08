class SectionSerializer < ActiveModel::Serializer
  cache expires_in: 6.hours

  attribute :id
  attribute :creator_id, if: :can_view_creator?
  attribute :deleted_by_id, if: :can_view_deleted_by?

  attribute :title
  attribute :description
  # attribute :logo_url, if: -> { object.logo.file.present? } do
  #   object.logo.url
  # end
  attribute :conversations_count
  attribute :posts_count, if: :can_view_deleted_posts?
  attribute :visible_posts_count
  attribute :deleted

  attribute :created_at
  attribute :updated_at

  belongs_to :creator, serializer: UserSerializer, if: :can_view_creator?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_by?

  def can_view_deleted_posts?
    current_user.try(:admin?)
  end

  def can_view_creator?
    current_user.try(:admin?)
  end

  def can_view_deleted_by?
    current_user.try(:admin?)
  end
end
