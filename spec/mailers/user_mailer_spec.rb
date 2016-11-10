require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let :user do
    create :user
  end

  describe '.confirmation' do
    let :mail do
      UserMailer.confirmation(user.id)
    end

    it 'sends a confirmation email to the user' do
      expect(mail.to).to eq [user.email]
      expect(mail.subject).to eq 'Welcome!'
    end

    it "sets the user's last email timestamp" do
      expect do
        mail.body
      end.to change { user.reload.last_email_at }
         .from(nil)
         .to be_within(1.minute).of(Time.zone.now)
    end
  end

  describe '.inactive' do
    let :mail do
      UserMailer.inactive(user.id)
    end

    it 'sends a user inactive user to the user' do
      expect(mail.to).to eq [user.email]
      expect(mail.subject).to eq 'We miss you!'
    end

    it "sets the user's last email timestamp" do
      expect do
        mail.body
      end.to change { user.reload.last_email_at }
         .from(nil)
         .to be_within(1.minute).of(Time.zone.now)
    end
  end
end
