class SiteController < ApplicationController

	#before_action :authenticate_user!
	
	skip_before_filter :authenticate_user!, :except => [:home, :admin_settings]

	layout :resolve_layout

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def index
	end

	def home
		@news = News.order(id: :desc).first(5)
		@about = News.order(id: :desc).last(1)
		if current_user.role.blank?
			@welcome_user = "Hi! #{current_user.username.humanize}, welcome to RIMES Climate data analysis system. You are now registered as a user with limited privileges and can use only a few of the functionalities. In case you want to upgrade your account to a ADVANCED USER please post us an request. We will consider and upon approved will provide you with full access. "
		else
			@welcome_user = "Hi! #{current_user.username.humanize}, you are #{current_user.role.humanize} user. "
		end
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
