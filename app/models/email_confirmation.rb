# frozen_string_literal: true
# == Schema Information
#
# Table name: email_confirmations
#
#  token      :uuid             not null, primary key
#  user_id    :integer          not null
#  status     :string           default("open"), not null
#  old_email  :string
#  new_email  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_email_confirmations_on_status   (status)
#  index_email_confirmations_on_token    (token) UNIQUE
#  index_email_confirmations_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_422b33d86c  (user_id => users.id)
#

class EmailConfirmation < ApplicationRecord
  self.primary_key = :token

  belongs_to :user, inverse_of: :email_confirmations

  enum status: {
    open:      'open',
    confirmed: 'confirmed',
    expired:   'expired'
  }

  validates :token, presence: true, uniqueness: true
  validates :user, :status, presence: true

  validate :status_can_be_changed, on: :update

  before_validation :generate_token, on: :create

  after_create :expire_other_confirmations
  after_save :confirm_user_email, if: -> { status_changed?(to: 'confirmed') }

  after_commit :send_email_confirmation, on: :create

private

  def status_can_be_changed
    errors.add(:status, "can't be changed") unless status_was == 'open'
  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def expire_other_confirmations
    EmailConfirmation.where(status: 'open', user: user)
                     .where.not(token: token)
                     .update_all(status: 'expired')
  end

  def confirm_user_email
    user.touch(:email_confirmed_at)
  end

  def send_email_confirmation
    # TODO : Move to own mailer.
    UserMailer.confirmation(user_id).deliver_later
  end
end
