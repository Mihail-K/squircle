# frozen_string_literal: true
namespace :mock do
  desc 'Creates a large dataset of conversations and posts'
  task :data, [:sections, :conversations] => :environment do |_, args|
    sections_count      = [(args[:sections] || 3).to_i, 1].max
    conversations_count = [(args[:conversations] || 10).to_i, 1].max

    FactoryGirl.create_list(:section, sections_count).each do |section|
      print '*'.blue
      conversations_count.times do
        FactoryGirl.create :conversation, section: section, posts_count: Faker::Number.between(1, 25)
        print '.'.green
      end
    end

    print "\n"
  end

  desc 'Adds avatars to all users without them'
  task avatars: :environment do
    User.where(avatar: nil).find_each do |user|
      user.update(remote_avatar_url: Faker::Avatar.image)
      print '.'.green
    end

    print "\n"
  end

  desc 'Creates a small set of reports for existing data'
  task :reports, [:count] => :environment do |_, args|
    reports_count = [(args[:count] || 10).to_i, 1].max
    reportables   = Report::ALLOWED_TYPES.map(&:constantize).select(&:exists?)

    reports_count.times do
      klass = reportables.sample
      index = rand(0...klass.count)

      FactoryGirl.create :report, reportable: klass.offset(index).first
      print '.'.green
    end

    print "\n"
  end
end if Rails.env.development?
