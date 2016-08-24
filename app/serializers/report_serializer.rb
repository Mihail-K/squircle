class ReportSerializer < ActiveModel::Serializer
  attribute :id
  attribute :reportable_id
  attribute :reportable_type
  attribute :creator_id

  attribute :status
  attribute :closed
  attribute :description
  attribute :created_at
  attribute :updated_at

  belongs_to :reportable, polymorphic: true
  belongs_to :creator, serializer: UserSerializer
end
