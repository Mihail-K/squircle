FactoryGirl.define do
  factory :role do
    name { Faker::Company.profession }
    description { Faker::Hipster.paragraph }

    # - Permissions - #

    trait :with_permissions do
      permissions_count 1
    end

    transient do
      permissions_count 0
    end

    after :build do |role, e|
      e.permissions = build_list :permission, e.permissions_count
    end
  end
end
