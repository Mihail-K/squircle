require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let :conversation do
    build :conversation
  end

  it 'has a valid factory' do
    expect(conversation).to be_valid
  end

  describe '.posts_count' do
    let :conversation do
      create :conversation, :with_posts
    end

    it 'matches the number of posts' do
      expect(conversation.posts_count).not_to eq 0
      expect(conversation.posts_count).to eq conversation.posts.count
    end

    it 'increases when a post is created' do
      old_count = conversation.posts_count
      create :post, conversation: conversation
      expect(conversation.posts_count).to be > old_count
    end

    it 'decreases when a post is destroyed' do
      old_count = conversation.posts_count
      conversation.posts.last.destroy!
      expect(conversation.posts_count).to be < old_count
    end
  end

  describe '.visible_posts_count' do
    let :conversation do
      create :conversation, :with_posts
    end

    it 'matches the number of posts' do
      expect(conversation.visible_posts_count).not_to eq 0
      expect(conversation.visible_posts_count).to eq conversation.posts.visible.count
    end

    it 'increases when a post is created' do
      expect do
        create :post, conversation: conversation
      end.to change { conversation.visible_posts_count }.by(1)
    end

    it 'decreases when a post is destroyed' do
      expect do
        conversation.posts.sample.destroy
      end.to change { conversation.visible_posts_count }.by(-1)
    end

    it 'decreases when a post is marked deleted' do
      expect do
        conversation.posts.sample.update deleted: true, deleted_by: create(:user)
      end.to change { conversation.visible_posts_count }.by(-1)
    end
  end
end
