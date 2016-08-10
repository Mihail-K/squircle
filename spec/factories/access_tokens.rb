FactoryGirl.define do
  factory :access_token, class: Doorkeeper::AccessToken do
    application
    resource_owner_id { create(:user).id }
    token { SecureRandom.uuid }
  end
end
