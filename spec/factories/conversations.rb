FactoryGirl.define do
  factory :conversation do
    association :author, factory: :user, strategy: :build
    association :section, strategy: :build
    deleted false

    trait :with_posts do
      post_count 1
    end

    transient do
      post_count 1
    end

    after :build do |conversation, e|
      if e.post_count.positive?
        conversation.posts = build_list :post, e.post_count, conversation: conversation
      end
    end
  end
end
