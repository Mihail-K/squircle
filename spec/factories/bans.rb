FactoryGirl.define do
  factory :ban do
    user
    association :creator, factory: :user

    reason { Faker::Hipster.paragraph }
    expires_at { Faker::Date.between(1.hour.from_now, 1.year.from_now) }

    trait :permanent do
      expires_at nil
    end
  end
end
