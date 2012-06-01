TrailsForwardWorld::Application.routes.draw do
  devise_for :users

  match "/users/authenticate_for_token" => "users#authenticate_for_token"

  resources :users do
    resources :players, :only => [:index, :show, :update, :edit, :destroy]
  end

  resources :worlds, :only => [:index, :show] do
    member do
      get :time_left_for_turn
    end

    resources :players, :only => [:index, :show, :create], :controller => :world_players do
      collection do
        put :submit_turn
      end
      get :bids_placed
      get :bids_received
    end

    resources :listings, :only => [:index, :create, :show] do
      collection do
        get 'active', :controller => :listings, :action => :index_active
      end

      resources :bids, :controller => :listing_bids, :except => [:destroy, :update] do
        member do
          post :accept
        end
      end
    end

    resources :megatiles, :only => [:index, :show] do
      resources :listings, :except => [:destroy, :update]

      resources :bids, :except => [:destroy, :update] do
        post :accept
        post :reject
      end

      member do
        get :appraise
      end

      collection do
        get 'appraise', :controller => :megatiles, :action => :appraise_list
      end
    end

    resources :resource_tiles, :only => [:show, :update] do
      member do
        post :bulldoze
        post :clearcut
        post :build
      end

      collection do
        post 'diameter_limit_cut', controller: :resource_tiles, action: :diameter_limit_cut_list
        post 'partial_selection_cut', controller: :resource_tiles, action: :partial_selection_cut_list
        post 'bulldoze', :controller => :resource_tiles, :action => :bulldoze_list
        post 'clearcut', :controller => :resource_tiles, :action => :clearcut_list
        post 'build', :controller => :resource_tiles, :action => :build_list
        get 'permitted_actions', :controller => :resource_tiles, :action => :permitted_actions
      end
    end
  end

  root :to => "welcome#index"
end
