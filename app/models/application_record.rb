class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :deleted_by, class_name: 'User'

  validates :deleted_by, presence: true, if: :deleted?

  before_save :set_deleted_at_timestamp, if: -> { deleted_changed?(to: true) }

  scope :hidden, -> {
    where deleted: true
  }

  scope :visible, -> {
    where deleted: false
  }

private

  def set_deleted_at_timestamp
    self.deleted_at = Time.zone.now
  end
end
