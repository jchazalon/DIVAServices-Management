Rails.application.routes.draw do

  # Set the main page as the default landing page
  root to: 'home#index'

  # Create a route to the FAQ page
  get '/faq', to:'home#faq'
  
  # Generate routes for users by devise. Overwrite the registrations controller with our own.
  devise_for :users, controllers: { registrations: "registrations" }

  # Generate CRUD routes for the algorithms.
  resources :algorithms do
    get '/exceptions', to: 'algorithms#exceptions', on: :member
    get '/status', to: 'algorithms#status', on: :member
    get '/edit', to: 'algorithms#edit', on: :member
    post '/publish', to: 'algorithms#publish', on: :member
    post '/recover', to: 'algorithms#recover', on: :member
    post '/revert', to: 'algorithms#revert', on: :member
    get '/terms', to: 'algorithm_wizard#terms', on: :collection
    # Generate the wizard routes by wicked. Define the controller name.
    resources :algorithm_wizard, controller: 'algorithm_wizard'
    # Use an own controller for input parameter sorting.
    resources :input_parameters do
       put :sort, on: :collection
    end
  end
end
