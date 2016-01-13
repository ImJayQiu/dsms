Rails.application.routes.draw do

	get '/temps/:name' => 'cmip5s#temps', :as => :tmp_img

	namespace :settings do
		resources :inds
		resources :ensembles
		resources :experiments
		resources :datasetpaths
		resources :temporals
		resources :datamodels
		resources :variables
		resources :mips
	end

	resources :datasets

	resources :cmip5s do
		collection do
			get :checkfiles
			get :daily
			get :monthly
			get :daily_analysis
			get :monthly_analysis
			get :mult
			get :mult_analysis
			get :info
		end
	end


	resources :cdoanalysises do
		collection do
			get :indices
			get :info
			get :seasonal
			get :sma
			get :yearly
			get :map
			get :ymonmean
			get :lonlat
		end
	end

	resources :site do
		collection do
			get 'index'
			get 'home' 
			get 'admin_settings' 
		end
	end
	devise_for :users #, controllers: { sessions: "users/sessions" }
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

	root 'site#index'
end
