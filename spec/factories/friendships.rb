FactoryGirl.define do
  factory :friendship do
    association :user, strategy: :build
    association :friend, factory: :user, strategy: :build
  end
end
