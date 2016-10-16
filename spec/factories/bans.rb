# frozen_string_literal: true
FactoryGirl.define do
  factory :ban do
    association :user, strategy: :build
    association :creator, factory: :user, role: :admin, strategy: :build

    reason { Faker::Hipster.paragraph }
    expires_at { Faker::Date.between(1.day.from_now, 1.year.from_now) }

    trait :permanent do
      expires_at nil
    end

    trait :expired do
      expires_at { Faker::Date.between(1.year.ago, 1.day.ago) }
    end
  end
end
