# frozen_string_literal: true
FactoryGirl.define do
  factory :post do
    association :author, factory: :user, strategy: :build

    title { Faker::Book.title }
    body { Faker::Hipster.paragraph }

    after :build do |post|
      if post.conversation.nil?
        post.conversation = create :conversation, author: post.author, post_count: 0, posts: [post]
      end
    end
  end
end
