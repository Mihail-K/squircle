class User < ActiveRecord::Base
  has_many :characters, -> { visible }, inverse_of: :user
  has_many :created_characters, -> { visible }, foreign_key: :creator_id, class_name: 'Character'

  has_many :posts, -> { visible }, inverse_of: :author

  has_secure_token :email_token
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true
  validates :date_of_birth, presence: true

  after_commit :regenerate_email_token, if: :email_changed?

  after_commit :send_email_confirmation, if: -> {
    previous_changes.key?(:email)
  }

  def send_email_confirmation
    # TODO
  end
end
