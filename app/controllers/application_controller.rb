class ApplicationController < ActionController::Base

	before_action :configure_permitted_parameters, if: :devise_controller?
	layout :layout_by_resource

	def after_sign_out_path_for(resource_or_scope)
		root_path
	end


	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) << :username
		devise_parameter_sanitizer.for(:account_update) << :username
	end

	def layout_by_resource
		if devise_controller? and user_signed_in?
			'login'
		else
			'login'
		#	'index'
		end
	end

end
