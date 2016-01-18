class SiteController < ApplicationController
	#before_action :authenticate_user!

	layout :resolve_layout

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def index
	end

	def home
		@news = News.order(id: :desc).first(5)
		@about = News.order(id: :desc).last(1)
	end

	def admin_settings
	end
	private 

	def resolve_layout
		case action_name
		when "index"
			"index"
		else
			"home"
		end
	end 

end
