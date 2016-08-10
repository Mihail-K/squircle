require 'rails_helper'

RSpec.describe User, type: :model do
  let :user do
    build :user
  end

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user.email = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the email is already taken' do
    create :user, email: user.email
    expect(user).not_to be_valid
  end

  it 'is not valid without a display name' do
    user.display_name = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the display name is already taken' do
    create :user, display_name: user.display_name
    expect(user).not_to be_valid
  end

  it 'is not valid without a date of birth' do
    user.date_of_birth = nil
    expect(user).not_to be_valid
  end

  it 'is not valid if the date of birth is in the future' do
    user.date_of_birth = Faker::Date.forward 1
    expect(user).not_to be_valid
  end

  it 'is not valid if the date is more than 100 years in the past, on creation' do
    user.date_of_birth = 100.years.ago
    expect(user).not_to be_valid

    user.date_of_birth = Faker::Date.between 50.years.ago, 13.years.ago
    expect(user.save).to be_truthy

    user.date_of_birth = 100.years.ago
    expect(user).to be_valid
  end

  it 'generates an email token on creation' do
    user.save
    expect(user.email_token).to be_present
  end

  it 'generates a new email token whenever the email is changed' do
    user.save
    old_token = user.email_token

    user.update email: Faker::Internet.email
    expect(user.email_token).not_to eq old_token
  end

  describe 'with bans' do
    let :user do
      create :user, :with_bans
    end

    it 'has a valid factory' do
      expect(user).to be_valid
      expect(user.bans).not_to be_empty
    end

    it 'marks the user as banned' do
      expect(user.banned?).to be true
    end
  end
end
