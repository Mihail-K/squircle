require 'rails_helper'

RSpec.describe Post, type: :model do
  let :post do
    build :post
  end

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

  describe '.character' do
    it 'is valid when it is owned by the author' do
      post.character = create :character, user: post.author
      expect(post).to be_valid
    end

    it 'is not valid if the character is not owned by the author' do
      post.character = create :character
      expect(post).not_to be_valid
    end

    it 'is valid when the author is an admin' do
      post.character = create :character
      post.author.admin = true
      expect(post).to be_valid
    end
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

  describe '.deleted' do
    before :each do
      post.update deleted: true
    end

    it 'prevents the post from being edited' do
      post.editor = create :user
      expect(post).not_to be_valid
    end

    it %(doesn't prevent the post from being edited by an admin) do
      post.editor = create :user, admin: true
      expect(post).to be_valid
    end

    it 'hides it from the general public' do
      expect(Post.visible.exists?(id: post)).to be false
    end
  end
end
