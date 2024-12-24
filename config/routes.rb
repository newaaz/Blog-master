Rails.application.routes.draw do
  root 'posts#index'

  devise_for :users

  devise_scope :user do
    get "/users/sign_out", as: "sign_out", to: "devise/sessions#destroy"
  end

  mount ActionCable.server => '/cable'

  resources :posts
  resources :users

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
  end
end
