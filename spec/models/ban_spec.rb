require 'rails_helper'

RSpec.describe Ban, type: :model do
  let :ban do
    build :ban
  end

  it 'has a valid factory' do
    expect(ban).to be_valid
  end

  it 'is not permanent if it has an expiration date' do
    expect(ban.permanent?).to be false
  end

  it 'is active if the expiration date is in the past' do
    expect(ban.expired?).to be false
  end

  it 'expires when the expiration date has passed' do
    ban.expires_at = 1.day.ago
    expect(ban.expired?).to be true
  end

  it 'is permanent if the expiration date is blank' do
    ban.expires_at = nil
    expect(ban.permanent?).to be true
  end

  it 'never expires if its permanent' do
    ban.expires_at = nil
    expect(ban.expired?).to be false
  end

  it 'can only be created by an admin' do
    ban.creator = build :user
    expect(ban).not_to be_valid
  end

  it 'cannot be assigned to a different user' do
    new_user = build :user

    ban.save
    ban.update user: new_user
    expect(ban.reload.user).not_to eq new_user
  end

  it 'cannot be assigned to a different creator' do
    new_user = build :user, admin: true

    ban.save
    ban.update creator: new_user
    expect(ban.reload.creator).not_to eq new_user
  end

  it 'cannot apply to its creator' do
    ban.user = ban.creator
    expect(ban).not_to be_valid
  end
end
