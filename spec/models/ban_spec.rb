# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Ban, type: :model do
  let :ban do
    build :ban
  end

  it_behaves_like SoftDeletable

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

  it 'cannot apply to its creator' do
    ban.user = ban.creator
    expect(ban).not_to be_valid
  end

  describe '.active' do
    let :ban do
      create :ban
    end

    it 'includes bans that expire in the future' do
      expect(Ban.active.exists?(id: ban)).to be true
    end

    it 'includes bans without an exipiry (permanent)' do
      ban.update expires_at: nil

      expect(Ban.active.exists?(id: ban)).to be true
    end

    it 'does not include bans the expire in the past' do
      ban.update expires_at: Faker::Date.between(1.year.ago, 1.hour.ago)

      expect(Ban.active.exists?(id: ban)).to be false
    end

    it 'does not include bans that have been deleted' do
      ban.update deleted: true, deleted_by: create(:user)

      expect(Ban.active.exists?(id: ban)).to be false
    end
  end

  describe '.inactive' do
    let :ban do
      create :ban, :expired
    end

    it 'includes bans that expire in the past' do
      expect(Ban.inactive.exists?(id: ban)).to be true
    end

    it 'does not include bans without an expiry (permanent)' do
      ban.update expires_at: nil

      expect(Ban.inactive.exists?(id: ban)).to be false
    end

    it 'does not include bans that expire in the future' do
      ban.update expires_at: Faker::Date.between(1.hour.from_now, 1.year.from_now)

      expect(Ban.inactive.exists?(id: ban)).to be false
    end

    it 'includes bans that have been deleted' do
      ban.update deleted: true, deleted_by: create(:user)

      expect(Ban.inactive.exists?(id: ban)).to be true
    end
  end
end
