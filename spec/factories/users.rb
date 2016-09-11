FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    date_of_birth { Faker::Date.between(50.years.ago, 13.years.ago) }

    display_name {
      Faker::Internet.user_name + Faker::Number.number(Faker::Number.between(0, 4)).to_s
    }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    password '12345678'
    password_confirmation '12345678'

    banned false
    deleted false

    transient do
      role :user
    end

    after :build do |user, e|
      user.roles << Role.find_by!(name: e.role) unless user.roles.exists?(name: e.role)
    end

    # - Avatar - #

    trait :with_avatar do
      remote_avatar_url { Faker::Avatar.image }
    end

    # - Characters - #

    trait :with_characters do
      characters_count Faker::Number.between(1, 10)
    end

    transient do
      characters_count 0
    end

    after :build do |user, e|
      user.characters = build_list :character, e.characters_count, user: user
    end

    # - Bans - #

    trait :with_bans do
      bans_count 1
    end

    transient do
      bans_count 0
    end

    after :build do |user, e|
      user.bans = build_list :ban, e.bans_count, user: user
    end

    # - Posts - #

    trait :with_posts do
      posts_count 1
    end

    transient do
      posts_count 0
    end

    after :build do |user, e|
      user.posts = build_list :post, e.posts_count, author: user
    end
  end
end
