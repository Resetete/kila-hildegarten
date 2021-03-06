Rails.application.routes.draw do
  devise_for :admins
  root 'pages#home'
  get 'contact', to: 'pages#contact'
  get 'team', to: 'pages#team'
  get 'parents', to: 'pages#parents'
  get 'photos', to: 'pages#photos'
  get 'imprint', to: 'pages#imprint'

  resources :team_members # test first that it works, then restrict, only: [:new, :create, :destroy]
  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
