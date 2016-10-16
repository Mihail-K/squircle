# frozen_string_literal: true
Doorkeeper.configure do
  orm :active_record

  resource_owner_from_credentials do
    User.visible
        .find_by(email: params[:email] || params[:username])
        .try(:authenticate, params[:password])
  end

  access_token_expires_in 3.months

  grant_flows %w(authorization_code client_credentials password)
end
