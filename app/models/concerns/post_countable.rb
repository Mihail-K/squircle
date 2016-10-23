# frozen_string_literal: true
module PostCountable
  extend ActiveSupport::Concern

  included do
    scope :set_posts_counts, -> { find_each(&:set_posts_count) }
  end

  def set_posts_count
    update_columns(posts_count: countable_posts.count)
  end

protected

  def countable_posts
    posts.visible
  end
end
