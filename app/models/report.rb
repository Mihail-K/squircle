# frozen_string_literal: true
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
# Foreign Keys
#
#  fk_rails_0fcc82136b  (deleted_by_id => users.id)
#  fk_rails_b493e55f53  (creator_id => users.id)
#  fk_rails_db90b47c42  (closed_by_id => users.id)
#

class Report < ApplicationRecord
  include SoftDeletable

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
  validates :reportable_type, inclusion: { in: %w(Character Conversation Post User) }
  validates :creator, presence: true
  validates :closed_by, presence: true, if: :closed?

  validates :status, presence: true
  validates :description, presence: true, length: { in: 10..1000 }

  before_save :set_closed_at, if: -> { status_changed? from: 'open' }

  def closed?
    status != 'open'
  end

  alias closed closed?

  def set_closed_at
    self.closed_at = Time.zone.now
  end
end
