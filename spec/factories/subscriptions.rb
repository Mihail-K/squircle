FactoryGirl.define do
  factory :subscription do
    association :user, strategy: :build
    association :conversation, strategy: :build
  end
end
