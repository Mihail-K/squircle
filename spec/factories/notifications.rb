# frozen_string_literal: true
FactoryGirl.define do
  factory :notification do
    association :user, strategy: :build
    association :targetable, factory: :post, strategy: :build

    title { Faker::Book.title }

    trait :character do
      association :targetable, factory: :character, strategy: :build
    end

    trait :conversation do
      association :targetable, factory: :conversation, strategy: :build
    end

    trait :post do
      association :targetable, factory: :post, strategy: :build
    end

    trait :user do
      association :targetable, factory: :user, strategy: :build
    end
  end
end
