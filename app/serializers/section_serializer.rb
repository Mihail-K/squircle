class SectionSerializer < ApplicationSerializer
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

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :creator, serializer: UserSerializer, if: :can_view_creator?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_sections?

  def can_view_creator?
    allowed_to?(:create_sections)
  end

  def can_view_deleted_sections?
    allowed_to?(:view_deleted_sections)
  end
end
