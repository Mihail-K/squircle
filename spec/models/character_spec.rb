require 'rails_helper'

RSpec.describe Character, type: :model do
  let :character do
    build :character
  end

  it 'has a valid factory' do
    expect(character).to be_valid
  end

  it 'is not valid without a name' do
    character.name = nil
    expect(character).not_to be_valid
  end

  it 'is not valid without a user' do
    character.user = nil
    expect(character).not_to be_valid
  end
end
