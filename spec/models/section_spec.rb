# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Section, type: :model do
  let :section do
    build :section
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(section).to be_valid
  end

  it 'is not valid without a title' do
    section.title = nil
    expect(section).not_to be_valid
  end

  it 'is not valid if the description is too long' do
    section.description = Faker::Lorem.characters(1001)
    expect(section).not_to be_valid
  end

  it 'is not valid without a creator' do
    section.creator = nil
    expect(section).not_to be_valid
  end

  it "queues a job to update posts counts when it's deleted" do
    section = create :section

    expect do
      section.delete
    end.to have_enqueued_job(SectionPostsCountJob).on_queue('low')
  end

  describe '.conversations_count' do
    let :section do
      create :section
    end

    it 'is zero by default' do
      expect(section.conversations_count).to be_zero
    end

    it 'increases when a conversation is created' do
      expect do
        create :conversation, section: section
      end.to change { section.conversations_count }.by(1)
    end

    it 'decreases when a conversation is deleted' do
      conversation = create :conversation, section: section

      expect do
        conversation.delete
      end.to change { section.conversations_count }.by(-1)
    end

    it 'increases when a conversation is restored' do
      conversation = create :conversation, section: section
      conversation.delete

      expect do
        conversation.restore
      end.to change { section.conversations_count }.by(1)
    end

    it 'decreases when a conversation is destroyed' do
      conversation = create :conversation, section: section

      expect do
        conversation.destroy
      end.to change { section.conversations_count }.by(-1)
    end
  end
end
