FactoryGirl.define do
  factory :password_reset do
    association :user, strategy: :build
    email { user&.email || Faker::Internet.email }

    trait :without_user do
      user nil
      email { Faker::Internet.email }
    end

    trait :closed do
      status 'closed'
      password { Faker::Internet.password }
      password_confirmation { password }
    end
  end
end
