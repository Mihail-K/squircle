Rails.application.routes.draw do
  use_doorkeeper

  resources :bans

  resources :characters do
    resources :conversations, only: :index
    resources :posts, only: :index
  end
  resources :conversations do
    resources :posts, only: %i(index create)
  end

  resources :permissions, only: %i(index show)
  resources :posts

  resources :reports
  resources :roles

  resources :sections do
    resources :conversations, only: :index
  end

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
