Rails.application.routes.draw do
  use_doorkeeper

  resources :characters, only: %i(index create show update destroy) do
    resources :posts, only: :index
  end
  resources :conversations, only: %i(index create show update destroy) do
    resources :posts, only: %i(index create)
  end

  resources :posts, only: %i(index create show update destroy)

  resources :users, only: %i(index create show update destroy) do
    get :me, on: :collection

    resources :characters, only: :index
    resources :conversations, only: :index
    resources :posts, only: :index
  end
end
