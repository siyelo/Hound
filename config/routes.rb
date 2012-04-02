Hound::Application.routes.draw do
  devise_for :users, skip: :invitations, controllers: {registrations: "registrations"} do
    get 'activate' => 'devise/invitations#edit'
    put 'activate' => 'devise/invitations#update'
  end

  mount Resque::Server, :at => "/resque"

  resources :reminders
  resources :notifications, only: [:update, :edit]
  resources :snooze, only: [:show, :edit]
  resources :email_aliases

  authenticated :user do
    root :to => "reminders#index"
  end

  root :to => 'static_page#index'
  match '/:action(.html)' => 'static_page#:action'
end
