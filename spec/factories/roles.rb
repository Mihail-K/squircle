FactoryGirl.define do
  factory :role do
    name { Faker::Company.profession }
    description { Faker::Hipster.paragraph }
  end
end
