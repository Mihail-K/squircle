FactoryGirl.define do
  factory :post do
    association :author, factory: :user, strategy: :build

    title { Faker::Book.title }
    body { Faker::Hipster.paragraph }

    after :build do |post|
      post.conversation ||= build :conversation, first_post: post
    end
  end
end
