Rails.application.routes.draw do

  authenticated :user do
    root to: "home#index"
  end

  devise_scope :user do
    root to: "users/sessions#new"
  end

  get 'groups/new'
  get 'groups/manage'
  get 'home/impressum'
  get 'home/index'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', confirmations: 'users/confirmations', passwords: 'users/passwords' }
  resources :users do
    collection do
      put :update_user_role
    end
  end#, only: [:index, :show]


  resources :teams
  get '/groups/my_groups', to: 'groups#my_groups'
  get '/groups/group_requests', to: 'groups#group_requests'

  resources :groups do
    put :create_group_in_threema
  end


  resources :members


end
