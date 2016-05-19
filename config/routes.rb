Rails.application.routes.draw do

  root to: 'algorithms#index'
  devise_for :users, controllers: { registrations: "registrations" }
  resources :algorithms do
    get '/status', to: 'algorithms#status', on: :member
    get '/edit', to: 'algorithms#edit', on: :member
    post '/publish', to: 'algorithms#publish', on: :member
    post '/recover', to: 'algorithms#recover', on: :member
    post '/copy', to: 'algorithms#copy', on: :member #XXX Dev only
    get '/terms', to: 'algorithm_wizard#terms', on: :collection
    resources :algorithm_wizard, controller: 'algorithm_wizard'
    resources :input_parameters do
       put :sort, on: :collection
    end
  end
end
