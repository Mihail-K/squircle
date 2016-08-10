FactoryGirl.define do
  factory :character do
    association :user, factory: :user, strategy: :build

    name { Faker::Pokemon.name }
    title { Faker::Name.title }
    description { Faker::Hipster.paragraph }

    deleted false
  end
end
