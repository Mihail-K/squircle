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
      password_reset.save
    end.to change { password_reset.user }.from(nil).to(user)
  end

  it 'sends an email when created' do
    expect do
      password_reset.save
    end.to have_enqueued_job(ActionMailer::DeliveryJob)
      .with('PasswordResetMailer', 'opened', 'deliver_now', password_reset)
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
      password_reset.password_confirmation = Faker::Internet.password
      expect(password_reset).to be_invalid
    end

    it "changes the user's password" do
      expect do
        password_reset.save
      end.to change { password_reset.user.password_digest }
    end

    it 'sends an email when the password has been changed' do
      expect do
        password_reset.save
      end.to have_enqueued_job(ActionMailer::DeliveryJob)
        .with('PasswordResetMailer', 'closed', 'deliver_now', password_reset)
    end

    it 'has no affect when not attached to a user' do
      expect { password_reset.save }.not_to raise_error
    end
  end
end
