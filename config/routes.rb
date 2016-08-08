Rails.application.routes.draw do
  use_doorkeeper

  resources :characters, only: %i(index create show update destroy)

  resources :users, only: %i(index show create update destroy) do
    get :me, on: :collection

    resources :characters, only: :index
  end
end
