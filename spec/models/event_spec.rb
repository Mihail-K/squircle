# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Event, type: :model do
  let :event do
    build :event
  end

  it 'has a valid factory' do
    expect(event).to be_valid
  end

  it 'is invalid without a URL' do
    event.url = nil
    expect(event).to be_invalid
  end

  it 'is invalid without a controller' do
    event.controller = nil
    expect(event).to be_invalid
  end

  it 'is invalid without a method' do
    event.method = nil
    expect(event).to be_invalid
  end

  it 'is invalid without an action' do
    event.action = nil
    expect(event).to be_invalid
  end

  it 'is invalid without a status' do
    event.status = nil
    expect(event).to be_invalid
  end
end
