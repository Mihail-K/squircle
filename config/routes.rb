# frozen_string_literal: true
Rails.application.routes.draw do
  use_doorkeeper

  shallow do
    resources :bans

    resources :characters do
      resources :conversations, only: :index
      resources :posts, only: :index
    end
    resources :conversations do
      resources :posts
    end

    resources :permissions, only: %i(index show)
    resources :posts

    resources :reports
    resources :roles

    resources :sections do
      resources :conversations, only: :index
    end
    resources :subscriptions, only: %i(index show create destroy)

    resources :users do
      get :me, on: :collection

      resources :bans, only: :index
      resources :characters, only: :index
      resources :conversations, only: :index
      resources :posts, only: :index
      resources :reports, only: :index
      resources :roles, only: :index
    end
  end
end
