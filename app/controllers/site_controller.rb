class SiteController < ApplicationController
	#before_action :authenticate_user!

	layout :site_layout 

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def index
	end
	



	private

	def site_layout

		case action_name

		when "index"
			"index"
		end

	end

end 
