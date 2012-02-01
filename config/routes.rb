RadMeet::Application.routes.draw do
  devise_for :users

  mount Resque::Server, :at => "/resque"

  resources :reminders, only: [:index, :edit, :update]
  resources :notifications, only: [:update, :edit]
  resources :snooze, only: [:show, :edit]

  authenticated :user do
    root :to => "reminders#index"
  end

  root :to => 'static_page#index'

end
