Rails.application.routes.draw do
  devise_for :users
  resources :premium_rates
  resources :members
  resources :coverages
  resources :dependent_coverages
  resources :group_benefits
  resources :group_premia
  resources :dependents
  resources :batches
  resources :benefits
  resources :posts

  resources :coverages do
    get :selected, on: :member
  end

  #get 'pages/home'
  #get 'pages/about'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#index"
end
