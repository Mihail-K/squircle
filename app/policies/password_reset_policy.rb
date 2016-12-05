# frozen_string_literal: true
class PasswordResetPolicy < ApplicationPolicy
  def permitted_attributes_for_create
    :email
  end

  def permitted_attributes_for_update
    %i(status password password_confirmation)
  end
end
