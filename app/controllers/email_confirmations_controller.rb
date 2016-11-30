# frozen_string_literal: true
class EmailConfirmationsController < ApplicationController
  before_action :set_email_confirmation

  def show
    render json: @email_confirmation
  end

  def update
    @email_confirmation.update!(email_confirmation_params)

    render json: @email_confirmation
  end

private

  def email_confirmation_params
    params.require(:email_confirmation).permit(:status)
  end

  def set_email_confirmation
    @email_confirmation = EmailConfirmation.includes(:user).find(params[:token])
  end
end
