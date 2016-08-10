FactoryGirl.define do
  factory :conversation do
    association :author, factory: :user
    association :first_post, factory: :post, strategy: :build
  end
end
