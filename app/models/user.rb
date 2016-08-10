class User < ActiveRecord::Base
  has_many :bans, -> { active }, inverse_of: :user
  has_many :previous_bans, -> { expired }, class_name: 'Ban'
  has_many :issued_bans, foreign_key: :creator_id, class_name: 'Ban'

  has_many :characters, -> { visible }, inverse_of: :user
  has_many :created_characters, -> { visible }, foreign_key: :creator_id, class_name: 'Character'

  has_many :posts, -> { visible }, inverse_of: :author

  has_secure_token :email_token
  has_secure_password

  mount_uploader :avatar, AvatarUploader

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true

  validates :date_of_birth, presence: true
  validates :date_of_birth, timeliness: { before: :today, type: :date }
  validates :date_of_birth, timeliness: { after: -> { 100.years.ago } }, on: :create

  after_commit :regenerate_email_token, if: -> { previous_changes.key?(:email) }
  after_commit :send_email_confirmation, if: -> { previous_changes.key?(:email) }

  scope :banned, -> {
    where banned: true
  }

  scope :not_banned, -> {
    where banned: false
  }

  scope :visible, -> {
    where deleted: false
  }

  def send_email_confirmation
    # TODO
  end
end
