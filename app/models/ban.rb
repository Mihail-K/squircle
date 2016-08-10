# == Schema Information
#
# Table name: bans
#
#  id         :integer          not null, primary key
#  reason     :string           not null
#  expires_at :datetime
#  user_id    :integer          not null
#  creator_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bans_on_creator_id  (creator_id)
#  index_bans_on_user_id     (user_id)
#

class Ban < ActiveRecord::Base
  belongs_to :user, inverse_of: :bans
  belongs_to :creator, class_name: 'User'

  validates :user, presence: true
  validates :creator, presence: true
  validates :reason, presence: true

  after_create :apply_ban_to_user, unless: :expired?

  scope :active, -> {
    where 'bans.expires_at >= ?', DateTime.now.utc
  }

  scope :expired, -> {
    where 'bans.expires_at < ?', DateTime.now.utc
  }

  scope :permanent, -> {
    where expires_at: nil
  }

  def expired?
    expires_at.present? && expires_at.past?
  end

  def permanent?
    expires_at.nil?
  end

  alias_method :expired, :expired?
  alias_method :permanent, :permanent?

  def apply_ban_to_user
    user.update! banned: true
  end
end
