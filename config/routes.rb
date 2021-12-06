Rails.application.routes.draw do
  devise_for :admins
  root 'pages#home'
  get 'contact', to: 'pages#contact'

  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
