FactoryGirl.define do
  factory :conversation do
    association :author, factory: :user, strategy: :build
    section
    deleted false

    trait :with_posts do
      post_count { Faker::Number.between(1, 15) }
    end

    transient do
      post_count 1
    end

    after :build do |conversation, e|
      if e.post_count.positive?
        conversation.posts = build_list :post, e.post_count, conversation: conversation
      end
    end

    after :create do |conversation|
      result = Conversation.where(id: conversation)
                           .pluck(:posts_count, :visible_posts_count)
                           .first
      conversation.posts_count = result[0]
      conversation.visible_posts_count = result[1]
    end
  end
end
