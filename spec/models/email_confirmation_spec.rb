# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EmailConfirmation, type: :model do
  let :email_confirmation do
    build :email_confirmation
  end

  it 'has a valid factory' do
    expect(email_confirmation).to be_valid
  end

  it 'is invalid without a user' do
    email_confirmation.user = nil
    expect(email_confirmation).to be_invalid
  end

  it 'is invalid without a status' do
    email_confirmation.status = nil
    expect(email_confirmation).to be_invalid
  end

  it 'sends an email after creation' do
    email_confirmation.user.save

    expect do
      email_confirmation.save
    end.to have_enqueued_job(ActionMailer::DeliveryJob)
      .with('UserMailer', 'confirmation', 'deliver_now', email_confirmation.user.id)
  end

  it 'marks other email confirmations as expired' do
    other = create :email_confirmation, user: email_confirmation.user

    expect do
      email_confirmation.save
    end.to change { other.reload.status }.from('open').to('expired')
  end

  it 'touches the user email confirmed timestamp when it becomes confirmed' do
    expect do
      email_confirmation.confirmed!
    end.to change { email_confirmation.user.email_confirmed_at }
      .to be_within(1.minute).of(Time.current)
  end
end
