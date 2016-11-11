# frozen_string_literal: true
FactoryGirl.define do
  factory :config do
    key { "#{Faker::Hacker.noun}-#{Faker::Hacker.noun}" }
    value { Faker::Number.number(10) }
  end
end
