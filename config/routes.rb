Rails.application.routes.draw do
  devise_for :admins
  root 'pages#home'
  get 'contact', to: 'pages#contact'
  get 'parents', to: 'pages#parents'
  get 'photos', to: 'pages#photos'
  get 'imprint', to: 'pages#imprint'

  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
