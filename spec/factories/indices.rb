# frozen_string_literal: true
FactoryGirl.define do
  factory :index do
    association :indexable, factory: :post, strategy: :build
  end
end
