# frozen_string_literal: true
FactoryGirl.define do
  factory :visit do
    ip { Faker::Internet.ip_v4_address }

    trait :with_user do
      association :user, strategy: :build
    end
  end
end
