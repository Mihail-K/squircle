# frozen_string_literal: true
module FloodLimitable
  extend ActiveSupport::Concern

  included do
    before_action :check_flood_limit, only: :create, unless: -> {
      current_user.try(:allowed_to?, :ignore_flood_limit)
    }
  end

  def check_flood_limit
    return unless Post.flood.exists?(author: current_user)
    # Prevent posts from being made more than once per 20 seconds.
    @post = Post.new { |post| post.errors.add :base, :flood_limit }
    raise ActiveRecord::RecordInvalid, @post
  end
end
