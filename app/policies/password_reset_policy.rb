# frozen_string_literal: true
class PasswordResetPolicy < ApplicationPolicy
  alias password_reset record

  def show?
    scope.exists?(token: password_reset)
  end

  def create?
    true
  end

  def update?
    true
  end

  def permitted_attributes_for_create
    :email
  end

  def permitted_attributes_for_update
    %i(status password password_confirmation)
  end
end
