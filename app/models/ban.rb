# == Schema Information
#
# Table name: bans
#
#  id            :integer          not null, primary key
#  reason        :string           not null
#  expires_at    :datetime
#  user_id       :integer          not null
#  creator_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted       :boolean          default(FALSE), not null
#  deleted_by_id :integer
#  deleted_at    :datetime
#
# Indexes
#
#  index_bans_on_creator_id     (creator_id)
#  index_bans_on_deleted_by_id  (deleted_by_id)
#  index_bans_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_070022cd76  (user_id => users.id)
#  fk_rails_1bb4452a95  (deleted_by_id => users.id)
#  fk_rails_7e7295a4fe  (creator_id => users.id)
#

class Ban < ApplicationRecord
  belongs_to :user, inverse_of: :bans
  belongs_to :creator, class_name: 'User'

  validates :user, presence: true
  validates :creator, presence: true
  validates :reason, presence: true, length: { in: 10..1000 }

  validate :creator_is_not_user, on: :create

  after_create :apply_ban_to_user, if: :active?

  scope :active, -> {
    where Ban.arel_table[:deleted]
             .eq(false)
             .and(
               Ban.arel_table[:expires_at]
                  .eq(nil)
                  .or(
                    Ban.arel_table[:expires_at]
                       .gteq(Time.zone.now)
                  )
             )
  }

  scope :inactive, -> {
    where Ban.arel_table[:deleted]
             .eq(true)
             .or(
               Ban.arel_table[:expires_at]
                  .not_eq(nil)
                  .and(
                    Ban.arel_table[:expires_at]
                       .lt(Time.zone.now)
                  )
             )
  }

  scope :permanent, -> {
    where expires_at: nil
  }

  def active?
    !deleted? && !expired?
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def permanent?
    expires_at.nil?
  end

  alias_method :expired, :expired?
  alias_method :permanent, :permanent?

private

  def creator_is_not_user
    errors.add :base, 'you cannot ban yourself' if user_id == creator_id
  end

  def apply_ban_to_user
    user.roles << Role.find_by!(name: 'banned') if active? && !user.banned?
  end
end
