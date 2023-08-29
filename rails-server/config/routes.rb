Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  resources :users
  get 'welcome/index'

  resources :movies
  post 'signin', to: 'authentication#signin'
  post 'signup', to: 'authentication#signup'
  root 'welcome#index'
  post 'movies/like', to: 'movies#like'
end
