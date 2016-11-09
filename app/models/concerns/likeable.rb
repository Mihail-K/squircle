# frozen_string_literal: true
module Likeable
  extend ActiveSupport::Concern

  included do
    has_many :likes, as: :likeable, dependent: :destroy, inverse_of: :likeable
    has_many :likers, through: :likes, source: :user

    scope :most_liked, -> {
      order(likes_count: :desc).where.not(likes_count: 0)
    }
  end

  def liked?
    likes_count.nonzero?
  end

  alias liked liked?
end
