# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Notification, type: :model do
  let :notification do
    build :notification
  end

  it 'has a valid factory' do
    expect(notification).to be_valid
  end

  it 'is invalid without a user' do
    notification.user = nil
    expect(notification).to be_invalid
  end

  it 'is invalid without a target' do
    notification.targetable = nil
    expect(notification).to be_invalid
  end

  it 'is invalid without a title' do
    notification.title = nil
    expect(notification).to be_invalid
  end
end
