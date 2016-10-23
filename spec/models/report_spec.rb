# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Report, type: :model do
  let :report do
    build :report
  end

  it_behaves_like SoftDeletable

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

  it 'is closed when its status is not open' do
    report.status = 'resolved'
    expect(report.closed?).to be true
  end

  it 'is not valid if closed without a closing user' do
    report.status = 'resolved'
    expect(report).not_to be_valid
  end

  it 'sets a closed_at timestamp when it becomes closed' do
    report.update status: 'resolved', closed_by: create(:user)
    expect(report.status).to eq 'resolved'
    expect(report.closed_at).not_to be nil
  end
end
