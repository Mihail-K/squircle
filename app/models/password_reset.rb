# frozen_string_literal: true
# == Schema Information
#
# Table name: password_resets
#
#  token      :uuid             not null, primary key
#  user_id    :integer
#  status     :string           default("open"), not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  request_ip :inet
#
# Indexes
#
#  index_password_resets_on_token    (token) UNIQUE
#  index_password_resets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_526379cd99  (user_id => users.id)
#

class PasswordReset < ApplicationRecord
  self.primary_key = :token

  attr_accessor :password

  belongs_to :user, inverse_of: :password_resets

  enum status: {
    open:   'open',
    closed: 'closed'
  }

  validates :token, presence: true, uniqueness: true
  validates :status, :email, presence: true

  with_options if: -> { status_changed?(to: 'closed') } do |o|
    o.validates :password, presence: true, confirmation: true
    o.validates :password_confirmation, presence: true
  end

  validate :status_can_be_changed, if: :status_changed?

  before_validation :generate_token, on: :create
  before_validation :set_user, on: :create, if: -> { user.blank? }

  after_save :update_user_password, if: -> { user.present? && status_changed?(to: 'closed') }

  after_commit :send_password_reset, on: :create, if: -> { user.present? }

private

  def generate_token
    self.token = SecureRandom.uuid
  end

  def set_user
    self.user = User.find_by(email: email)
  end

  def status_can_be_changed
    errors.add(:status, "can't be changed") unless status_was == 'open'
  end

  def update_user_password
    user.update!(password: password, password_confirmation: password_confirmation)
  end

  def send_password_reset
    # TODO : Mailer
  end
end
