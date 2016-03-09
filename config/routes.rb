Rails.application.routes.draw do

  root to: 'algorithms#index'
  devise_for :users
  resources :algorithms do
    resources :algorithm_wizard, controller: 'algorithm_wizard'
      resources :input_parameters
  end

end
