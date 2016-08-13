FactoryGirl.define do
  factory :conversation do
    association :author, factory: :user, strategy: :build
    association :first_post, factory: :post, strategy: :build

    trait :with_posts do
      post_count { Faker::Number.between(1, 25) }
    end

    transient do
      post_count 0
    end

    after :build do |conversation, e|
      if e.post_count.positive?
        conversation.posts = build_list :post, e.post_count, conversation: conversation
        conversation.first_post = conversation.posts.first
      end
    end
  end
end
