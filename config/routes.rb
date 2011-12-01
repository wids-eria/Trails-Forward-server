TrailsForwardWorld::Application.routes.draw do
  devise_for :users

  match "/users/authenticate_for_token" => "users#authenticate_for_token"

  resources :users do
    resources :players, :only => [:index, :show, :update, :edit, :destroy]
  end

  resources :worlds, :only => [:index, :show] do
    resources :players, :only => [:index, :show] do
      get :bids_placed
      get :bids_received
    end

    resources :listings, :only => [:index, :create, :show] do
      collection do
        get 'active', :controller => :listings, :action => :index_active
      end
    end

    resources :megatiles, :only => [:index, :show] do
      resources :listings, :except => [:destroy, :update]

      resources :bids, :except => [:destroy, :update] do
        post :accept
        post :reject
        post :cancel
      end

      member do
        get :appraise
      end

      collection do
        get 'appraise', :controller => :megatiles, :action => :appraise_list
      end
    end

    resources :resource_tiles, :only => [:show] do
      member do
        post :bulldoze
        post :clearcut
        post :build
      end

      collection do
        post 'bulldoze', :controller => :resource_tiles, :action => :bulldoze_list
        post 'clearcut', :controller => :resource_tiles, :action => :clearcut_list
        post 'build', :controller => :resource_tiles, :action => :build_list
      end
    end
  end

  root :to => "welcome#index"
end
