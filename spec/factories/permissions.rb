# frozen_string_literal: true
FactoryGirl.define do
  factory :permission, class: Permissible::Permission do
    name { Faker::Hacker.verb + '_' + Faker::Hacker.noun }
    description { Faker::Hipster.paragraph }
  end
end
