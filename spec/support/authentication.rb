RSpec.shared_context 'authentication', shared_context: :metadata do
  let! :active_user do
    create :user
  end

  let :token do
    create :access_token, resource_owner_id: active_user.id
  end
end