class SectionSerializer < ActiveModel::Serializer
  cache expires_in: 6.hours

  attribute :id
  attribute :creator_id, if: :can_view_creator?

  attribute :title
  attribute :description
  # attribute :logo_url, if: -> { object.logo.file.present? } do
  #   object.logo.url
  # end
  attribute :conversations_count
  attribute :deleted

  belongs_to :creator, if: :can_view_creator?

  def can_view_creator?
    current_user.try(:admin?)
  end
end
