# frozen_string_literal: true
FactoryGirl.define do
  factory :email_confirmation do
    association :user, strategy: :build

    old_email { user.email }
    new_email { Faker::Internet.email }
  end
end
