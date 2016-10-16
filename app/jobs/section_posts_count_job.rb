# frozen_string_literal: true
class SectionPostsCountJob < ApplicationJob
  queue_as :low

  def perform(section_id)
    section = Section.find(section_id)

    # Recalculate author post counts.
    section.post_authors.find_each do |author|
      author.update_columns(posts_count: author.posts.visible.count)
    end

    # Recalculate character post counts.
    section.post_characters.find_each do |character|
      character.update_columns(posts_count: character.posts.visible.count)
    end
  end
end
