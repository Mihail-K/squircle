require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let :conversation do
    build :conversation
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(conversation).to be_valid
  end

  describe '.posts_count' do
    let :conversation do
      create :conversation
    end

    it 'is 1 by default' do
      expect(conversation.posts_count).to eq 1
    end

    it 'is equal to the number of visible posts' do
      create_list :post, 3, conversation: conversation
      expect(conversation.posts_count).to eq 4
    end

    it 'increases when a post is created' do
      expect do
        create :post, conversation: conversation
      end.to change { conversation.posts_count }.from(1).to(2)
    end

    it 'decreases when a post is deleted' do
      post = create :post, conversation: conversation

      expect do
        post.update deleted: true, deleted_by: post.author
      end.to change { conversation.posts_count }.from(2).to(1)
    end

    it 'decreases when a post is destroyed' do
      post = create :post, conversation: conversation

      expect do
        post.destroy
      end.to change { conversation.posts_count }.from(2).to(1)
    end
  end
end
