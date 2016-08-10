require 'rails_helper'

RSpec.describe Ban, type: :model do
  before :each do
    @ban = build :ban
  end

  it 'has a valid factory' do
    expect(@ban).to be_valid
  end

  it 'is not permanent if it has an expiration date' do
    expect(@ban.permanent?).to be false
  end

  it 'is active if the expiration date is in the past' do
    expect(@ban.expired?).to be false
  end

  it 'expires when the expiration date has passed' do
    @ban.expires_at = Faker::Date.between 1.year.ago, 1.hour.ago
    expect(@ban.expired?).to be true
  end

  it 'is permanent if the expiration date is blank' do
    @ban.expires_at = nil
    expect(@ban.permanent?).to be true
  end

  it 'never expires if its permanent' do
    @ban.expires_at = nil
    expect(@ban.expired?).to be false
  end
end
