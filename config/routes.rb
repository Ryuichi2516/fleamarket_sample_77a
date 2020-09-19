Rails.application.routes.draw do

  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }
  devise_scope :user do
    get 'delivery_addresses', to: 'users/registrations#new_delivery_address'
    post 'delivery_addresses', to: 'users/registrations#create_delivery_address'
  end

  resources :users, only: [:show, :edit, :update] do
    member do
      get "logout"
      get "favorite"
    end
  end

  root 'products#index'
  resources :products do
    resources :favorites, only: [:create, :destroy] do
      collection do
        get 'search'
      end
    end
  end
  
end