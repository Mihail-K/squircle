# frozen_string_literal: true
RSpec.shared_context 'authentication', shared_context: :metadata do
  let! :active_user do
    create :user
  end

  let :access_token do
    create(:access_token, resource_owner_id: active_user.id).token
  end

  let :session do
    { access_token: access_token }
  end
end
