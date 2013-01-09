Hound::Application.routes.draw do
  devise_for :users, skip: [:invitations],
    controllers: { registrations: 'users/registrations' }
  as :user do
    get 'activate' => 'devise/invitations#edit'
    put 'activate' => 'devise/invitations#update'
  end

  mount Resque::Server, :at => "/resque"

  resources :reminders, except: [:new, :create]
  resources :inbound_email, only: [:index, :create]

  match 'confirmations/disable' => 'confirmations#disable', via: :get

  resource :settings, only: [:update, :edit] do
    put :update_password
  end
  resource :merge_users, only: [:create]
  get "settings" => "settings#edit", as: :settings
  resources :snooze, only: [:show, :edit]
  resources :email_aliases

  authenticated :user do
    root :to => "reminders#index"
  end

  root :to => 'static_page#index'
  get '/:action(.html)' => 'static_page#:action', as: :static_page
end
