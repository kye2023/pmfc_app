Rails.application.routes.draw do
  resources :user_details do 
    get :approve_user, on: :member
  end
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

  resources :batches do
    get :batch_submit, on: :member
    get :batch_download, on: :member
    get :batch_preview, on: :member
    collection do
      post :import
    end
    member do 
      get :import_cov
    end
    # post :import_coverages, on: :member
  end


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
