# frozen_string_literal: true
FactoryGirl.define do
  factory :event do
    controller 'UsersController'
    action 'index'
    status 200
    body({})

    add_attribute :method, 'GET'

    trait :with_user do
      association :user, strategy: :build
    end

    trait :with_visit do
      association :visit, strategy: :build
    end
  end
end
