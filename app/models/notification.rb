# frozen_string_literal: true
# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  targetable_type :string           not null
#  targetable_id   :integer          not null
#  title           :string           not null
#  read            :boolean          default(FALSE), not null
#  dismissed       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sourceable_type :string
#  sourceable_id   :integer
#
# Indexes
#
#  index_notifications_on_dismissed                          (dismissed)
#  index_notifications_on_read                               (read)
#  index_notifications_on_read_and_dismissed                 (read,dismissed)
#  index_notifications_on_sourceable_type_and_sourceable_id  (sourceable_type,sourceable_id)
#  index_notifications_on_targetable_type_and_targetable_id  (targetable_type,targetable_id)
#  index_notifications_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_b080fb4855  (user_id => users.id) ON DELETE => cascade
#

class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications
  belongs_to :targetable, polymorphic: true
  belongs_to :sourceable, polymorphic: true

  validates :user, presence: true
  validates :targetable, presence: true
  validates :title, presence: true

  scope :pending, -> {
    where(dismissed: false).order(read: :desc)
  }
end
