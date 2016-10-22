require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let :subscription do
    build :subscription
  end

  it 'has a valid factory' do
    expect(subscription).to be_valid
  end

  it 'is invalid without a user' do
    subscription.user = nil
    expect(subscription).to be_invalid
  end

  it 'is invalid without a conversation' do
    subscription.conversation = nil
    expect(subscription).to be_invalid
  end
end
