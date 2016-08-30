require 'rails_helper'

RSpec.describe Section, type: :model do
  let :section do
    build :section
  end

  it 'has a valid factory' do
    expect(section).to be_valid
  end

  it 'is not valid without a title' do
    section.title = nil
    expect(section).not_to be_valid
  end

  it 'is not valid if the description is too short' do
    section.description = Faker::Lorem.characters(4)
    expect(section).not_to be_valid
  end

  it 'is not valid if the description is too long' do
    section.description = Faker::Lorem.characters(1001)
    expect(section).not_to be_valid
  end

  it 'is not valid without a creator' do
    section.creator = nil
    expect(section).not_to be_valid
  end
end
