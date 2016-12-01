# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PasswordReset, type: :model do
  let :password_reset do
    build :password_reset
  end

  it 'has a valid factory' do
    expect(password_reset).to be_valid
  end

  it 'is invalid without an email' do
    password_reset.email = nil
    expect(password_reset).to be_invalid
  end

  it 'is invalid without a status' do
    password_reset.status = nil
    expect(password_reset).to be_invalid
  end

  it 'sets the user based on the email' do
    password_reset = build :password_reset, :without_user
    user = create :user, email: password_reset.email

    expect do
      password_reset.validate
    end.to change { password_reset.user }.from(nil).to(user)
  end

  context 'when it becomes closed' do
    let :password_reset do
      build :password_reset, :closed
    end

    it 'has a valid factory' do
      expect(password_reset).to be_valid
    end

    it 'is invalid without a password' do
      password_reset.password = nil
      expect(password_reset).to be_invalid
    end

    it 'is invalid without a password confirmation' do
      password_reset.password_confirmation = nil
      expect(password_reset).to be_invalid
    end

    it "is invalid if the confirmation doesn't match" do
      password_reset.password_confirmation = '1234'
      expect(password_reset).to be_invalid
    end

    it "changes the user's password" do
      expect do
        password_reset.save
      end.to change { password_reset.user.password_digest }
    end
  end
end
