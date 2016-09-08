# == Schema Information
#
# Table name: reports
#
#  id              :integer          not null, primary key
#  reportable_type :string           not null
#  reportable_id   :integer          not null
#  status          :string           default("open"), not null
#  description     :text
#  creator_id      :integer          not null
#  deleted         :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  closed_at       :datetime
#  closed_by_id    :integer
#  deleted_by_id   :integer
#  deleted_at      :datetime
#
# Indexes
#
#  index_reports_on_closed_by_id                       (closed_by_id)
#  index_reports_on_creator_id                         (creator_id)
#  index_reports_on_deleted                            (deleted)
#  index_reports_on_deleted_by_id                      (deleted_by_id)
#  index_reports_on_reportable_type_and_reportable_id  (reportable_type,reportable_id)
#  index_reports_on_status                             (status)
#

class Report < ApplicationRecord
  belongs_to :reportable, polymorphic: true
  belongs_to :creator, class_name: 'User'
  belongs_to :closed_by, class_name: 'User'

  enum status: {
    open:     'open',
    resolved: 'resolved',
    wontfix:  'wontfix',
    spite:    'spite'
  }

  validates :reportable, presence: true
  validates :creator, presence: true
  validates :closed_by, presence: true, if: :closed?

  validates :status, presence: true
  validates :description, presence: true, length: { in: 10..1000 }

  before_save :set_closed_at_timestamp, if: -> { status_changed? from: 'open' }

  def closed?
    status != 'open'
  end

  alias_method :closed, :closed?

  def set_closed_at_timestamp
    self.closed_at = Time.zone.now
  end
end
