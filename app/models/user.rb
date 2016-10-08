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

  has_and_belongs_to_many :roles, -> { not_deleted }
  has_many :role_permissions, through: :roles

  inherits_permissions_from :roles

  has_many :bans, -> { active }, inverse_of: :user
  has_many :previous_bans, -> { inactive }, class_name: 'Ban'
  has_many :issued_bans, foreign_key: :creator_id, class_name: 'Ban'

  has_many :characters, inverse_of: :user
  has_many :created_characters, foreign_key: :creator_id, class_name: 'Character'

  has_many :posts, foreign_key: :author_id, inverse_of: :author

  has_secure_token :email_token
  has_secure_password

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  validates :email, presence: true, uniqueness: true
  validates :display_name, presence: true, uniqueness: true

  validates :date_of_birth, presence: true

  with_options if: :date_of_birth_changed? do |o|
    o.validates :date_of_birth, timeliness: { before: :today, type: :date }
    o.validates :date_of_birth, timeliness: { after: -> { 100.years.ago }, type: :date }
  end

  before_create :assign_default_user_roles
  before_create :set_last_active_at_timestamp

  with_options if: -> { previous_changes.key?(:email) } do |o|
    o.after_commit :regenerate_email_token
    o.after_commit :send_email_confirmation
  end

  scope :banned, -> {
    joins(:roles).where(roles: { name: 'banned' })
  }

  scope :not_banned, -> {
    where.not(id: banned)
  }

  scope :no_active_bans, -> {
    joins(
      User.arel_table
          .outer_join(Ban.arel_table)
          .on(
            Ban.arel_table[:user_id]
               .eq(User.arel_table[:id])
               .and(
                 Ban.arel_table[:expires_at]
                    .gteq(Time.zone.now)
               )
          )
          .join_sources
    )
    .where bans: { id: nil }
  }

  scope :most_active, -> {
    not_banned.where(User.arel_table[:posts_count].gt(0))
              .order(posts_count: :desc)
  }

  scope :recently_active, -> {
    where User.arel_table[:last_active_at]
              .gteq(5.minutes.ago)
              .and(
                User.arel_table[:posts_count]
                    .gt(0)
              )
  }

private

  def set_last_active_at_timestamp
    self.last_active_at = Time.zone.now
  end

  def send_email_confirmation
    # TODO
  end

  def assign_default_user_roles
    roles << Role.find_by!(name: 'user') unless roles.any? { |role| role.name == 'user' }
  end
end
