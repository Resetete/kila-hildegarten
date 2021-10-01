Rails.application.routes.draw do
  root 'pages#home'
  get 'about_us', to: 'pages#about_us'

  resources :contents
end
