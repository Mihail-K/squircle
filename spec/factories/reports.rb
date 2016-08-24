FactoryGirl.define do
  factory :report do
    association :creator, factory: :user

    description { Faker::Lorem.paragraph }

    trait :reportable_character do
      association :reportable, factory: :character, strategy: :build
    end

    trait :reportable_conversation do
      association :reportable, factory: :conversation, strategy: :build
    end

    trait :reportable_post do
      association :reportable, factory: :post, strategy: :build
    end

    trait :reportable_user do
      association :reportable, factory: :user, strategy: :build
    end
  end
end