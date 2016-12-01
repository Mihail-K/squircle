# frozen_string_literal: true
Rails.application.routes.draw do
  use_doorkeeper

  shallow do
    resources :bans

    resources :characters
    resources :conversations

    resources :email_confirmations, only: %i(show update), param: :token

    resources :friendships, only: %i(index show create destroy)

    resources :indices, only: :index

    resources :likes, only: %i(index show create destroy)

    resources :notifications, only: %i(index show update destroy)

    resources :password_resets, only: %i(show create update), param: :token
    resources :permissions, only: %i(index show)
    resources :posts

    resources :reports
    resources :roles

    resources :sections
    resources :subscriptions, only: %i(index show create destroy)

    resources :users do
      get :me, on: :collection
    end
  end
end
