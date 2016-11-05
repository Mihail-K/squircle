# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let :friendship do
    build :friendship
  end

  it 'has a valid factory' do
    expect(friendship).to be_valid
  end

  it 'is invalid without a user' do
    friendship.user = nil
    expect(friendship).to be_invalid
  end

  it 'is invalid without a friend' do
    friendship.friend = nil
    expect(friendship).to be_invalid
  end

  it "is invalid when it's a duplicate" do
    friendship.save
    expect(build(:friendship, user: friendship.user, friend: friendship.friend)).to be_invalid
  end

  it 'is invalid if the user is also the friend' do
    friendship.friend = friendship.user
    expect(friendship).to be_invalid
  end

  it 'creates a notification' do
    expect do
      friendship.save
    end.to change { friendship.friend.notifications.count }.by(1)
  end
end
