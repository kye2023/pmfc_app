Rails.application.routes.draw do
  resources :group_benefits
  resources :group_premia
  resources :branches
  devise_for :users
  resources :premium_rates
  
  resources :members do
    collection do
      post :import
    end
  end

  resources :coverages
  
  resources :dependents do
    collection do
      post :import
    end
  end

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
