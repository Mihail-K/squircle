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
#  date_of_birth            :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  admin                    :boolean          default(TRUE), not null
#  characters_count         :integer          default(0), not null
#  created_characters_count :integer          default(0), not null
#  posts_count              :integer          default(0), not null
#  avatar                   :string
#  deleted                  :boolean          default(FALSE), not null
#  banned                   :boolean          default(FALSE), not null
#  visible_posts_count      :integer          default(0), not null
#
# Indexes
#
#  index_users_on_display_name  (display_name) UNIQUE
#  index_users_on_email         (email) UNIQUE
#  index_users_on_email_token   (email_token) UNIQUE
#

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
          .first
    )
    .where bans: { id: nil }
  }

  scope :visible, -> {
    where deleted: false
  }

  def send_email_confirmation
    # TODO
  end
end
