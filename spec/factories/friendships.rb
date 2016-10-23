# frozen_string_literal: true
FactoryGirl.define do
  factory :friendship do
    association :user, strategy: :build
    association :friend, factory: :user, strategy: :build
  end
end
