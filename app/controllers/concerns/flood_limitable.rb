module FloodLimitable
  extend ActiveSupport::Concern

  included do
    before_action :check_flood_limit, only: :create, unless: :admin?
  end

  def check_flood_limit
    if Post.flood.exists?(author: current_user)
      # Prevent posts from being made more than once per 20 seconds.
      raise ActiveRecord::RecordInvalid, @post = Post.new { |post|
        post.errors.add :base, 'you can only post once every 20 seconds'
      }
    end
  end
end
