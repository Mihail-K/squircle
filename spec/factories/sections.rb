FactoryGirl.define do
  factory :section do
    title { Faker::Book.title }
    description { Faker::Hipster.paragraph }
    deleted false

    association :creator, factory: :user, strategy: :build

    # - Conversations - #

    trait :with_conversations do
      conversations_count 1
    end

    transient do
      conversations_count 0
    end

    after :build do |section, e|
      section.conversations = build_list :conversation, e.conversations_count, section: section
    end
  end
end
