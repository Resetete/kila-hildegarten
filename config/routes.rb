Rails.application.routes.draw do
  devise_for :admins
  root 'pages#home'
  get 'about_us', to: 'pages#about_us'

  resources :contents
  resources :images
end
