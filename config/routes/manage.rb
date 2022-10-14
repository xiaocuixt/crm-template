namespace :manage do
  resources :users do
    member do
      get :edit_password
      post :update_password
    end
  end

  resources :products
end