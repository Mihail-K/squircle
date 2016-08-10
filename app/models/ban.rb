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
