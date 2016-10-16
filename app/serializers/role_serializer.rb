# frozen_string_literal: true
class RoleSerializer < ApplicationSerializer
  attribute :id
  attribute :deleted_by_id, if: :can_view_deleted_roles?

  attribute :name
  attribute :description
  attribute :deleted, if: :can_view_deleted_roles?

  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :can_view_deleted_roles?

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :deleted_by, if: :can_view_deleted_roles?

  def can_view_deleted_roles?
    current_user.try(:allowed_to?, :view_deleted_roles)
  end
end
