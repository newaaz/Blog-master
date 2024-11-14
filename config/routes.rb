Rails.application.routes.draw do
  root 'static_pages#home'

  devise_for :users

  resources :users
  resources :posts

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :posts, only: [:index, :edit, :update]
    resources :users, only: [:index, :new, :create]
  end
end
