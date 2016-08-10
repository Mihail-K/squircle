require 'rails_helper'

RSpec.describe Post, type: :model do
  before :each do
    @post = build :post
  end

  it 'has a valid factory' do
    expect(@post).to be_valid
  end

  it 'is invalid without an author' do
    @post.author = nil
    expect(@post).not_to be_valid
  end

  it 'is invalid without a conversation' do
    @post.conversation = nil
    expect(@post).not_to be_valid
  end

  it 'is invalid without a body' do
    @post.body = nil
    expect(@post).not_to be_valid
  end

  it 'is invalid if the body is too short' do
    @post.body = Faker::Lorem.characters Faker::Number.between(0, 9)
    expect(@post).not_to be_valid
  end

  it 'is invalid if the body is too long' do
    @post.body = Faker::Lorem.characters 10_001
    expect(@post).not_to be_valid
  end

  it 'is invalid if the character is not owned by the author' do
    @post.character = build :character
    expect(@post).not_to be_valid
  end

  it 'is valid if the character is owned by the author' do
    @post.character = create :character, user: @post.author
    expect(@post).to be_valid
  end

  it 'is valid if character is not owned by an admin' do
    @post.character = build :character
    @post.author.admin = true
    expect(@post).to be_valid
  end
end
