class SectionSerializer < ActiveModel::Serializer
  cache expires_in: 6.hours

  attribute :id
  attribute :creator_id, if: :can_view_creator?
  attribute :deleted_by_id, if: :can_view_deleted_sections?

  attribute :title
  attribute :description
  # attribute :logo_url, if: -> { object.logo.file.present? } do
  #   object.logo.url
  # end
  attribute :conversations_count
  attribute :posts_count
  attribute :deleted

  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :can_view_deleted_sections?

  belongs_to :creator, serializer: UserSerializer, if: :can_view_creator?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_sections?

  def can_view_creator?
    current_user.try(:admin?)
  end

  def can_view_deleted_sections?
    current_user.try(:admin?)
  end
end
