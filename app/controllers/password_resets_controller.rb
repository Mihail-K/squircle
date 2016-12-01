# frozen_string_literal: true
class PasswordResetsController < ApplicationController
  before_action :set_password_reset, only: %i(show update)

  def show
    render json: @password_reset
  end

  def create
    PasswordReset.create!(password_reset_params) do |password_reset|
      password_reset.request_ip = request.remote_ip
    end

    head :created
  end

  def update
    @password_reset.update!(password_reset_params)

    render json: @password_reset
  end

private

  def set_password_reset
    @password_reset = policy_scope(PasswordReset).find(params[:token])
  end
end
