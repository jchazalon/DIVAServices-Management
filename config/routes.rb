Rails.application.routes.draw do

  root to: 'algorithms#index'
  devise_for :users
  resources :algorithms

end
