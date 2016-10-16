# frozen_string_literal: true
class ReportSerializer < ApplicationSerializer
  attribute :id
  attribute :reportable_id
  attribute :reportable_type
  attribute :creator_id
  attribute :deleted_by_id, if: :can_view_deleted_reports?

  attribute :status
  attribute :closed
  attribute :deleted
  attribute :description
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :can_view_deleted_reports?
  attribute :closed_at

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :reportable, polymorphic: true
  belongs_to :creator, serializer: UserSerializer
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_reports?

  def can_view_deleted_reports?
    allowed_to?(:view_deleted_reports)
  end
end
