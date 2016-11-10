class UserMailer < ApplicationMailer
  after_action :set_last_email_at

  def confirmation(user_id)
    @user = User.find(user_id)

    mail to: @user.email, subject: 'Welcome!'
  end

  def inactive(user_id)
    @user = User.find(user_id)

    mail to: @user.email, subject: 'We miss you!'
  end

  def lost(user_id)
    @user = User.find(user_id)

    mail to: @user.email
  end

private

  def set_last_email_at
    @user.touch(:last_email_at)
  end
end
