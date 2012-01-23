RadMeet::Application.routes.draw do
  devise_for :users

  mount Resque::Server, :at => "/resque"

  resources :reminders, only: [:index]
  resources :notifications, only: [:edit]
  resources :snooze, only: [:update]
  root :to => 'static_page#index'
end
