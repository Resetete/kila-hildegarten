Rails.application.routes.draw do
  devise_for :admins
  root 'pages#home'
  get 'contact', to: 'pages#contact'
  get 'imprint', to: 'pages#imprint'

  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
