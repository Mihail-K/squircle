FactoryGirl.define do
  factory :permission do
    name { Faker::Hacker.verb + '_' + Faker::Hacker.noun }
    description { Faker::Hipster.paragraph }
  end
end
