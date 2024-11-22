Rails.application.routes.draw do
  resources :center_names do
    get :load_center
    get :add_new_center
    get :find_center
   
  end
  resources :user_details do 
    get :approve_user, on: :member
  end
  resources :group_benefits
  resources :group_premia
  resources :branches do
    get :load_branch
  end
  devise_for :users
  resources :premium_rates
  
  resources :members do
    collection do
      post :import
    end
  end

  resources :coverages do
    get :selected, on: :member
    patch :sgyrt_submit, on: :member # This is a PATCH route
    patch :lppi_submit, on: :member
    # get :sgyrt_submit, on: :member # This is a GET route
    get :check_residency
    get :coverage_history
    get :coverage_premium_benefits
    collection do
      get :renewal
    end
  end
  
  resources :dependents do
    get :age_validation
    collection do
      post :import
    end
  end

  resources :batches do
    get :unlisted_preview, on: :member
    get :batch_submit, on: :member
    get :batch_download, on: :member
    get :batch_preview, on: :member
    get :load_batch
    get :find_batch
    get :add_new_batch
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

  # resources :coverages do
  #   get :selected, on: :member
  # end

  #get 'pages/home'
  #get 'pages/about'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#index"
end
