FactoryGirl.define do
  factory :ban do
    user
    association :creator, factory: :user, admin: true

    reason { Faker::Hipster.paragraph }
    expires_at { Faker::Date.between(1.hour.from_now, 1.year.from_now) }

    trait :permanent do
      expires_at nil
    end

    trait :expired do
      expires_at { Faker::Date.between(1.year.ago, 1.hour.ago) }
    end
  end
end
