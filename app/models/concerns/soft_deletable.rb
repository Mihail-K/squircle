# frozen_string_literal: true
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    belongs_to :deleted_by, class_name: 'User'

    before_save :set_deleted_at, if: -> { deleted_changed?(to: true) }

    scope :deleted, -> {
      where deleted: true
    }

    scope :not_deleted, -> {
      where deleted: false
    }
  end

  def delete(deleted_by = nil)
    update(deleted: true, deleted_by: deleted_by)
  end

  def delete!(deleted_by = nil)
    update!(deleted: true, deleted_by: deleted_by)
  end

  def restore
    update(deleted: false)
  end

  def restore!
    update!(deleted: false)
  end

private

  def set_deleted_at
    self.deleted_at = Time.zone.now
  end
end
