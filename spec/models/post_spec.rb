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

  it 'is invalid if the character is not owned by the author' do
    post.character = build :character
    expect(post).not_to be_valid
  end

  it 'is valid if the character is owned by the author' do
    post.character = create :character, user: post.author
    expect(post).to be_valid
  end

  it 'is valid if character is not owned by an admin' do
    post.character = build :character
    post.author.admin = true
    expect(post).to be_valid
  end

  it 'cannot be edited if it has been deleted' do
    post.editor = create :user
    post.deleted = true
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
end
