# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SubscriptionLoader do
  let :user do
    create :user
  end

  let :conversation do
    create :conversation
  end

  it 'returns nil when the user is nil' do
    expect(described_class.new(nil).for(conversation)).to be_nil
  end

  it 'returns an empty hash if no subscriptions exist' do
    expect(described_class.new(user).for(conversation)).to be_empty
  end

  it 'returns a hash containing subscriptions to conversations' do
    subscription = create :subscription, user: user, conversation: conversation
    result       = described_class.new(user).for(conversation)

    expect(result).to have_key conversation.id
    expect(result[conversation.id]).to eq subscription
  end
end
