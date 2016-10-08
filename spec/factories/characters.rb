FactoryGirl.define do
  factory :character do
    association :creator, factory: :user, strategy: :build

    name { Faker::Pokemon.name }
    title { Faker::Name.title }
    description { Faker::Hipster.paragraph }

    after :build do |character|
      character.user ||= character.creator
    end
  end
end
