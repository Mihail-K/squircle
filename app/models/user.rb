# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string           not null
#  email_token              :string
#  email_confirmed_at       :datetime
#  password_digest          :string
#  display_name             :string
#  first_name               :string
#  last_name                :string
#  date_of_birth            :date             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  characters_count         :integer          default(0), not null
#  created_characters_count :integer          default(0), not null
#  posts_count              :integer          default(0), not null
#  avatar                   :string
#  deleted                  :boolean          default(FALSE), not null
#  banned                   :boolean          default(FALSE), not null
#  last_active_at           :datetime
#  deleted_by_id            :integer
#  deleted_at               :datetime
#  bucket                   :string           default("active"), not null
#  last_email_at            :datetime
#
# Indexes
#
#  index_users_on_deleted_by_id  (deleted_by_id)
#  index_users_on_display_name   (display_name) UNIQUE
#  index_users_on_email          (email) UNIQUE
#  index_users_on_email_token    (email_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_205180732b  (deleted_by_id => users.id)
#

class User < ApplicationRecord
  include Permissible::Model
  include Indexable
  include PostCountable
  include SoftDeletable

  has_and_belongs_to_many :roles, -> { not_deleted }
  has_many :role_permissions, through: :roles

  inherits_permissions_from :roles

  has_many :bans, -> { active }, inverse_of: :user
  has_many :previous_bans, -> { inactive }, class_name: 'Ban'
  has_many :issued_bans, foreign_key: :creator_id, class_name: 'Ban'

  has_many :characters, inverse_of: :user
  has_many :created_characters, foreign_key: :creator_id, class_name: 'Character'

  has_many :email_confirmations, inverse_of: :user, dependent: :delete_all
  has_many :password_resets, inverse_of: :user, dependent: :delete_all

  has_many :posts, foreign_key: :author_id, inverse_of: :author

  has_many :notifications, inverse_of: :user
  has_many :subscriptions, inverse_of: :user

  enum bucket: {
    active:   'active',
    inactive: 'inactive',
    lost:     'lost'
  }

  has_secure_password

  mount_uploader :avatar, AvatarUploader
  # process_in_background :avatar

  indexable primary: :display_name

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true
  validates :date_of_birth, presence: true

  with_options if: :date_of_birth_changed? do |o|
    o.validates :date_of_birth, timeliness: { before: :today, type: :date }
    o.validates :date_of_birth, timeliness: { after: -> { 100.years.ago }, type: :date }
  end

  before_create :assign_default_user_roles
  before_create :set_last_active_at_timestamp

  before_save :build_email_confirmation, if: -> { new_record? || email_changed? }

  with_options unless: :banned? do |o|
    o.after_commit :send_user_inactive_email, if: %i(bucket_previously_changed? inactive?)
    o.after_commit :send_user_lost_email, if: %i(bucket_previously_changed? lost?)
  end

  after_commit :send_user_unbanned_email, if: -> { banned_previously_changed? && !banned? }
  after_commit :update_display_name_caches, on: :update, if: :display_name_previously_changed?

  scope :banned, -> {
    where(banned: true)
  }

  scope :not_banned, -> {
    where(banned: false)
  }

  scope :no_active_bans, -> {
    left_joins(:bans).where(bans: { id: nil })
  }

  scope :most_active, -> {
    not_banned.where(User.arel_table[:posts_count].gt(0))
              .reorder(posts_count: :desc)
  }

  scope :recently_active, -> {
    not_banned.where(User.arel_table[:last_active_at].gteq(5.minutes.ago))
              .where(User.arel_table[:posts_count].gt(0))
              .reorder(last_active_at: :desc)
  }

private

  def assign_default_user_roles
    roles << Role.find_by!(name: 'user') unless roles.any? { |role| role.name == 'user' }
  end

  def set_last_active_at_timestamp
    self.last_active_at = Time.current
  end

  def build_email_confirmation
    email_confirmations.build(old_email: email_was, new_email: email)
  end

  def send_user_inactive_email
    UserMailer.inactive(id).deliver_later
  end

  def send_user_lost_email
    UserMailer.lost(id).deliver_later
  end

  def send_user_unbanned_email
    UserMailer.unbanned(id).deliver_later
  end

  def update_display_name_caches
    UserDisplayNameJob.perform_later(id)
  end
end
