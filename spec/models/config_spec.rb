require 'rails_helper'

RSpec.describe Config, type: :model do
  let :config do
    build :config
  end

  it 'has a valid factory' do
    expect(config).to be_valid
  end

  it 'is invalid without a key' do
    config.key = nil
    expect(config).to be_invalid
  end

  it 'is invalid with a duplicate key' do
    create :config, key: config.key
    expect(config).to be_invalid
  end
end
