class User < ActiveRecord::Base
  has_secure_token :email_token
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true
  validates :date_of_birth, presence: true

  after_commit :regenerate_email_token, if: :email_changed?

  after_commit :send_email_confirmation, if: -> {
    previous_changes.key?(:email)
  }

  def serializable_hash(options = nil)
    options ||= { }
    options[:only] ||= [
      :id, :display_name, :created_at
    ]
    super
  end

  def send_email_confirmation
    # TODO
  end
end
