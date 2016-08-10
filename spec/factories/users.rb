FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    date_of_birth { Faker::Date.between(50.years.ago, 13.years.ago) }

    display_name { Faker::Internet.user_name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    password '12345678'
    password_confirmation '12345678'

    admin false
  end
end
