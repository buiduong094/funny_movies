Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  resources :users
  get 'welcome/index'

  resources :movies
  post 'signin', to: 'authentication#signin'
  post 'signup', to: 'authentication#signup'
  root 'welcome#index'
end
