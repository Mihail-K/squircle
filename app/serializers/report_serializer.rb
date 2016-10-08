class ReportSerializer < ApplicationSerializer
  attribute :id
  attribute :reportable_id
  attribute :reportable_type
  attribute :creator_id

  attribute :status
  attribute :closed
  attribute :deleted
  attribute :description
  attribute :created_at
  attribute :updated_at
  attribute :closed_at

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :reportable, polymorphic: true
  belongs_to :creator, serializer: UserSerializer
end
