# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Like, type: :model do
  let :like do
    build :like
  end

  it 'has a valid factory' do
    expect(like).to be_valid
  end

  it 'is invalid without a user' do
    like.user = nil
    expect(like).to be_invalid
  end

  it 'is invalid without a likeable object' do
    like.likeable = nil
    expect(like).to be_invalid
  end

  it 'is invalid when a duplicate like exists' do
    like.save
    expect(like.dup).to be_invalid
  end
end
