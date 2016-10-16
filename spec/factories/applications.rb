# frozen_string_literal: true
FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    name { Faker::Company.name }
    uid { SecureRandom.uuid }
    secret { SecureRandom.uuid }
    redirect_uri { 'https://' + Faker::Internet.domain_name }
  end
end
