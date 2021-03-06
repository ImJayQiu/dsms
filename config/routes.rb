Rails.application.routes.draw do


  namespace :settings do
    resources :obs_models
  end
	namespace :ecmwf do
		resources :vars
		resources :types
	end

	resources :ecmwf do
		collection do
			get 'index'
			get 'debug'
			post 'debug_result'
			post 'analysis'
		end
	end

	resources :feedbacks

	resources :news

	resources :obs do
		collection do
			get :obs
			post :obs_analysis
		end
	end


	namespace :settings do
		resources :inds
		resources :ensembles
		resources :experiments
		resources :datasetpaths
		resources :temporals
		resources :datamodels
		resources :variables
		resources :mips
		resources :nexnasa_models
		resources :cordex_models
	end

	resources :datasets

	resources :cmip5s do
		collection do
			get :checkfiles
			get :daily
			post :daily_analysis
			get :mult
			post :mult_analysis
		end
	end

	resources :nexnasa do
		collection do
			get :daily
			post :daily_analysis
		end
	end

	resources :cordex do
		collection do
			get :daily
			post :daily_analysis
		end
	end


	resources :cdoanalysises do
		collection do
			post :indices
			post :info
			post :seasonal
			post :sma
			post :yearly
			post :map
			post :ymonmean
			post :lonlat
			post :shape
			post :ecmwf_level
		end
	end

	get '/pakistan', to: 'site#pakistan'
	get '/myanmar', to: 'site#myanmar'
	get '/srilanka', to: 'site#srilanka'
	get '/main', to: 'site#main'

	resources :site do
		collection do
			get 'index'
			get 'main'
			get 'pakistan'
			get 'myanmar'
			get 'srilanka'
			get 'home' 
			get 'admin_settings' 
			get 'debug'
		end
	end

	devise_for :users, :controllers => {:registrations => "users/registrations"}

	resources :users

	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	# root 'welcome#index'

	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
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

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

	root 'site#main'
end
