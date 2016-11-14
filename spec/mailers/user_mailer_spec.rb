# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let :user do
    create :user
  end

  shared_examples_for :last_email_at do
    it "sets the user's last email timestamp" do
      expect do
        mail.body
      end.to change { user.reload.last_email_at }
        .from(nil).to be_within(1.minute).of(Time.current)
    end
  end

  describe '.confirmation' do
    let :mail do
      UserMailer.confirmation(user.id)
    end

    it 'sends a confirmation email to the user' do
      expect(mail.to).to eq [user.email]
      expect(mail.subject).to eq 'Welcome!'
    end

    it_behaves_like :last_email_at
  end

  describe '.inactive' do
    let :mail do
      UserMailer.inactive(user.id)
    end

    it 'sends a user inactive email to the user' do
      expect(mail.to).to eq [user.email]
      expect(mail.subject).to eq 'We miss you!'
    end

    it_behaves_like :last_email_at
  end

  describe '.lost' do
    let :mail do
      UserMailer.lost(user.id)
    end

    it 'sends a user lost email to the user' do
      expect(mail.to).to eq [user.email]
    end

    it_behaves_like :last_email_at
  end

  describe '.unbanned' do
    let :mail do
      UserMailer.unbanned(user.id)
    end

    it 'sends a user unbanned email to the user' do
      expect(mail.to).to eq [user.email]
      expect(mail.subject).to eq 'Unbanned!'
    end

    it_behaves_like :last_email_at
  end
end
