FactoryGirl.define do
  factory :report do
    association :creator, factory: :user
    association :reportable, factory: :user, strategy: :build

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
  end
end
