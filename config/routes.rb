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
    end #megatiles
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


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
