require 'rails_helper'

RSpec.describe Post, type: :model do
  let :post do
    build :post
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(post).to be_valid
  end

  it 'is invalid without an author' do
    post.author = nil
    expect(post).not_to be_valid
  end

  it 'is invalid without a body' do
    post.body = nil
    expect(post).not_to be_valid
  end

  it 'is invalid if the body is too short' do
    post.body = Faker::Lorem.characters Faker::Number.between(0, 9)
    expect(post).not_to be_valid
  end

  it 'is invalid if the body is too long' do
    post.body = Faker::Lorem.characters 10_001
    expect(post).not_to be_valid
  end

  describe '.formatted_body' do
    before :each do
      post.save
    end

    it 'is generated when the post is saved' do
      expect(post.formatted_body).not_to be_blank
    end

    it 'is updated when the body changes' do
      old_formatted_body = post.formatted_body
      post.update body: Faker::Hipster.paragraph
      expect(post.formatted_body).not_to eq old_formatted_body
    end
  end

  describe '.visible' do
    let :post do
      create :post
    end

    it 'includes posts that are not deleted' do
      expect(Post.visible.exists?(id: post)).to be true
    end

    it 'does not include posts that are deleted' do
      post.update deleted: true, deleted_by: post.author
      expect(Post.visible.exists?(id: post)).to be false
    end

    it 'does not include posts that are in deleted conversations' do
      post.conversation.update deleted: true, deleted_by: post.author
      expect(Post.visible.exists?(id: post)).to be false
    end
  end

  describe '.editable_by?' do
    it 'is true when the user is the author of the post' do
      expect(post.editable_by?(post.author)).to be true
    end

    it 'is false when the user is not the author' do
      expect(post.editable_by?(create(:user))).to be false
    end

    it 'is true when the user is an admin' do
      expect(post.editable_by?(create(:user, role: :admin))).to be true
    end
  end
end
