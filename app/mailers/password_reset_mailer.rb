# frozen_string_literal: true
class PasswordResetMailer < ApplicationMailer
  def opened(password_reset)
    @password_reset = password_reset

    mail to: @password_reset.user.email, subject: 'Reset your password'
  end

  def closed(password_reset)
    @password_reset = password_reset

    mail to: @password_reset.user.email, subject: 'Password changed'
  end
end
