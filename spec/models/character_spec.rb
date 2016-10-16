# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Character, type: :model do
  let :character do
    build :character
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(character).to be_valid
  end

  it 'is not valid without a name' do
    character.name = nil
    expect(character).not_to be_valid
  end

  it 'is not valid if the name is too long' do
    character.name = Faker::Lorem.characters 31
    expect(character).not_to be_valid
  end

  it 'is not valid if the title is too short' do
    character.title = Faker::Lorem.characters 4
    expect(character).not_to be_valid
  end

  it 'is not valid if the title is too long' do
    character.title = Faker::Lorem.characters 101
    expect(character).not_to be_valid
  end

  it 'is not valid if the description is too long' do
    character.description = Faker::Lorem.characters 10_001
    expect(character).not_to be_valid
  end

  it 'is not valid without a user' do
    character.user = nil
    expect(character).not_to be_valid
  end

  it 'sets the user as its creator' do
    character.save
    expect(character.creator).to eq character.user
  end
end
