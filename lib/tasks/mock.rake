namespace :mock do
  task data: :environment do
    abort('Only usable in development') unless Rails.env.development?

    FactoryGirl.create_list(:section, 3).each do |section|
      posts_count = Faker::Number.between(1, 25)
      FactoryGirl.create_list(:conversation, 10, section: section, posts_count: posts_count)
    end
  end
end
