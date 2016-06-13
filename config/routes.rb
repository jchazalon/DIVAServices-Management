Rails.application.routes.draw do

  root to: 'home#index'
  devise_for :users, controllers: { registrations: "registrations" }
  authenticated :user do
    root to: 'algorithms#index', as: :authenticated_root
  end
  resources :algorithms do
    get '/exceptions', to: 'algorithms#exceptions', on: :member
    get '/status', to: 'algorithms#status', on: :member
    get '/edit', to: 'algorithms#edit', on: :member
    post '/publish', to: 'algorithms#publish', on: :member
    post '/recover', to: 'algorithms#recover', on: :member
    post '/revert', to: 'algorithms#revert', on: :member
    post '/copy', to: 'algorithms#copy', on: :member #XXX Dev only
    get '/terms', to: 'algorithm_wizard#terms', on: :collection
    resources :algorithm_wizard, controller: 'algorithm_wizard'
    resources :input_parameters do
       put :sort, on: :collection
    end
  end
  get '/faq', to:'home#faq'
end
