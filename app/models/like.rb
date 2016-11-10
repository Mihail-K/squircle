# frozen_string_literal: true
# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  likeable_type :string           not null
#  likeable_id   :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_likes_on_likeable_id_and_likeable_type_and_user_id  (likeable_id,likeable_type,user_id) UNIQUE
#  index_likes_on_likeable_type_and_likeable_id              (likeable_type,likeable_id)
#  index_likes_on_user_id                                    (user_id)
#
# Foreign Keys
#
#  fk_rails_1e09b5dabf  (user_id => users.id)
#

class Like < ApplicationRecord
  ALLOWED_TYPES = %w(Post).freeze

  belongs_to :likeable, polymorphic: true, inverse_of: :likes, counter_cache: :likes_count
  belongs_to :user

  validates :user, presence: true, uniqueness: { scope: :likeable }
  validates :likeable, presence: true

  def likeable_type
    super if ALLOWED_TYPES.include?(super)
  end
end
