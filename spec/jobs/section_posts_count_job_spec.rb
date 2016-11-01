# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SectionPostsCountJob, type: :job do
  let! :section do
    create :section
  end

  let! :conversation do
    create :conversation, section: section
  end

  let :author do
    conversation.posts.first.author
  end

  let :character do
    create :character
  end

  it 'updates the posts counts of authors in a section' do
    expect do
      section.soft_delete
      SectionPostsCountJob.perform_now(section.id)
    end.to change { author.reload.posts_count }.by(-1)

    expect do
      section.restore
      SectionPostsCountJob.perform_now(section.id)
    end.to change { author.reload.posts_count }.by(1)
  end

  it 'updates the posts count of characters in a section' do
    conversation.posts.first.update character: character

    expect do
      section.soft_delete
      SectionPostsCountJob.perform_now(section.id)
    end.to change { character.reload.posts_count }.by(-1)

    expect do
      section.restore
      SectionPostsCountJob.perform_now(section.id)
    end.to change { character.reload.posts_count }.by(1)
  end
end
