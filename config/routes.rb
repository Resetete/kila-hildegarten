Rails.application.routes.draw do
  devise_for :admins

  root 'pages#home'
  get 'contact', to: 'pages#contact'
  get 'team', to: 'pages#team'
  get 'parents', to: 'pages#parents'
  get 'photos', to: 'pages#photos'
  get 'imprint', to: 'pages#imprint'

  get 'webling_photos', to: 'webling_photos#index'
  get 'webling_photos/:id', to: 'webling_photos#show', as: 'webling_photo'

  resources :team_members
  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
