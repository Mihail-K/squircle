class Ban < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, class_name: 'User'

  validates :user, presence: true
  validates :creator, presence: true
  validates :reason, presence: true

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
end
