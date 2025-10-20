Rails.application.routes.draw do
  devise_for :admins

  root 'pages#home'
  get 'contact', to: 'pages#contact'
  get 'team', to: 'pages#team'
  get 'parents', to: 'pages#parents'
  get 'photos', to: 'pages#photos'
  get 'imprint', to: 'pages#imprint'

  get 'webling_photos/:id', to: 'webling_photos#show', as: 'webling_photo'

  resources 'webling_photos', only: [:index] do
    collection do
      post :zip_download
    end
  end
  resources :team_members
  resources :contents
  resources :images, only: [:new, :create, :destroy, :index]
end
