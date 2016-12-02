require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  let :password_reset do
    build :password_reset
  end

  describe '.opened' do
    let :mail do
      PasswordResetMailer.opened(password_reset)
    end

    it 'sends a password reset request to the user' do
      expect(mail.to).to eq [password_reset.user.email]
      expect(mail.subject).to eq 'Reset your password'
    end
  end

  describe '.closed' do
    let :mail do
      PasswordResetMailer.closed(password_reset)
    end

    it 'sends a password change notification to the user' do
      expect(mail.to).to eq [password_reset.user.email]
      expect(mail.subject).to eq 'Password changed'
    end
  end
end
