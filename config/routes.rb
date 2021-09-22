Rails.application.routes.draw do

  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]

  get 'distribution_lists/index'
  get 'distribution_lists/edit'

  get 'groups/new'
  get 'groups/manage'
  get 'home/impressum'
  get 'home/index'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', confirmations: 'users/confirmations', passwords: 'users/passwords', invitations: 'users/invitations' }
  resources :users do
    collection do
      put :update_user_role
    end
  end#, only: [:index, :show]
  match 'users/:id' => 'users#destroy', :via => :delete, :as => :admin_destroy_user


  devise_scope :user do
    authenticated :user do
      root 'home#index'
    end

    unauthenticated do
      root to: "users/sessions#new", as: :unauthenticated_root
    end
  end


  resources :teams
  resources :distribution_lists do
    get :send_message
    put :send_list_new_message
  end

  resources :feeds do
    get :new_message
    put :send_feed_new_message
  end

  get '/groups/group_requests', to: 'groups#group_requests'

  resources :groups do
    post :create_group_in_threema
  end


  resources :members

  match '*path' => redirect('/'), via: :get


end
