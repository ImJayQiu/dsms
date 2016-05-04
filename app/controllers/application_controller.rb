class ApplicationController < ActionController::Base


	before_action :authenticate_user!
	before_action :configure_permitted_parameters, if: :devise_controller?

	layout "main"


	rescue_from CanCan::AccessDenied do |exception|
		redirect_to root_url, :alert => exception.message
	end

	def after_sign_out_path_for(resource_or_scope)
		root_path
	end

	def after_sign_in_path_for(resource_or_scope)
		home_site_index_path
	end


	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) << :username
		devise_parameter_sanitizer.for(:account_update) << :username
	end

end
