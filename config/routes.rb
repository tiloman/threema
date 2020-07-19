Rails.application.routes.draw do
  get 'groups/new'
  get 'groups/manage'
  devise_for :users
  get 'home/index'
  root to: "home#index"

  resources :teams
  resources :groups
  resources :members


end
