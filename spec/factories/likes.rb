# frozen_string_literal: true
FactoryGirl.define do
  factory :like do
    association :user, strategy: :build
    association :likeable, factory: :post, strategy: :build
  end
end
