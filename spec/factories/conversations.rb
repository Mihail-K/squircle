# frozen_string_literal: true
FactoryGirl.define do
  factory :conversation do
    association :author, factory: :user, strategy: :build
    association :section, strategy: :build

    title { Faker::Book.title }

    trait :with_posts do
      posts_count 1
    end

    transient do
      posts_count 1
    end

    after :build do |conversation, e|
      conversation.posts = build_list :post, e.posts_count, conversation: conversation
    end

    trait :with_editor do
      association :editor, factory: :user, strategy: :build
    end
  end
end
