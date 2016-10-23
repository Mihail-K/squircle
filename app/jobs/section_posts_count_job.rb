# frozen_string_literal: true
class SectionPostsCountJob < ApplicationJob
  queue_as :low

  def perform(section_id)
    section = Section.find(section_id)
    section.post_authors.set_posts_counts
    section.post_characters.set_posts_counts
  end
end
