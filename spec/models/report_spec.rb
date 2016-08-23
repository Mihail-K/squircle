require 'rails_helper'

RSpec.describe Report, type: :model do
  let :report do
    build :report, :reportable_user
  end

  it 'has a valid factory' do
    expect(report).to be_valid
  end

  it 'is not valid without a description' do
    report.description = nil
    expect(report).not_to be_valid
  end

  it 'is not valid if the description is too short' do
    report.description = Faker::Lorem.characters(4)
    expect(report).not_to be_valid
  end

  it 'is not valid if the description is too long' do
    report.description = Faker::Lorem.characters(1001)
    expect(report).not_to be_valid
  end

  it 'is not valid without a creator' do
    report.creator = nil
    expect(report).not_to be_valid
  end

  it 'is not valid without a reportable object' do
    report.reportable = nil
    expect(report).not_to be_valid
  end

  it 'is not valid without a status' do
    report.status = nil
    expect(report).not_to be_valid
  end
end
