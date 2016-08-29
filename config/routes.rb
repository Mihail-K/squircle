Rails.application.routes.draw do
  use_doorkeeper

  resources :bans, only: %i(index create show update destroy)

  resources :characters, only: %i(index create show update destroy) do
    resources :conversations, only: :index
    resources :posts, only: :index
  end
  resources :conversations, only: %i(index create show update destroy) do
    resources :posts, only: %i(index create)
  end

  resources :posts, only: %i(index create show update destroy)

  resources :reports, only: %i(index create show update destroy)

  resources :sections, only: %i(index create show update destroy) do
    resources :conversations, only: :index
  end

  resources :users, only: %i(index create show update destroy) do
    get :me, on: :collection

    resources :bans, only: :index
    resources :characters, only: :index
    resources :conversations, only: :index
    resources :posts, only: :index
    resources :reports, only: :index
  end
end
