Rails.application.routes.draw do

  root to: 'algorithms#index'
  devise_for :users
  resources :algorithms do
    post '/recover', to: 'algorithms#recover', on: :member
    post '/copy', to: 'algorithms#copy', on: :member #XXX Dev only
    resources :algorithm_wizard, controller: 'algorithm_wizard'
    resources :input_parameters do
       put :sort, on: :collection
    end
  end
end
