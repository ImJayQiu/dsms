class Users::RegistrationsController < Devise::RegistrationsController


	before_action :set_user, only: [:show, :destroy]
	before_action :configure_permitted_parameters
	#before_filter :configure_sign_up_params, only: [:create]
	#before_filter :configure_account_update_params, only: [:update]

	# GET /resource/sign_up
	def new
		@user = User.new
		#super
	end

	# POST /resource
	def create
		@user = User.new(user_params)
		@admin = User.where(role: "admin")

		respond_to do |format|
			if @user.save
				UserNotifier.send_signup_email(@user).deliver_now
				UserNotifier.send_admin_email(@admin,@user).deliver_now
				format.html { redirect_to root_path, notice: "Dear #{@user.username}, your account was successfully created." }
				format.json { render :show, status: :created, location: @user }
			else
				format.html { render :new }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end

		#super
	end

	# GET /resource/edit
	def edit
		super
	end

	# PUT /resource
	def update
			super
	end



	# DELETE /resource
	def destroy
		super
	end

	# GET /resource/cancel
	# Forces the session data which is usually expired after sign
	# in to be expired now. This is useful if the user wants to
	# cancel oauth signing in/up in the middle of the process,
	# removing all OAuth session data.
	def cancel
		super
	end


	protected

	def configure_permitted_parameters

		#devise_parameter_sanitizer.for(:sign_up) << :username
		devise_parameter_sanitizer.for(:sign_up) { 
			|u| u.permit(:username, 
						 :email, 
						 :password, 
						 :password_confirmation,
						 :research_int,
						 :organization,
						 :country) }

		#devise_parameter_sanitizer.for(:account_update) << :username
		devise_parameter_sanitizer.for(:account_update) { 
			|u| u.permit(:username,
						 :email,
						 :current_password,
						 :password, 
						 :password_confirmation,
						 :research_int,
						 :organization,
						 :country) }

	end

	# You can put the params you want to permit in the empty array.
	#def configure_sign_up_params
	#	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit( :username, :email, :password, :password_confirmation, :research_int, :organization, :country )} 
	#end

	# You can put the params you want to permit in the empty array.
	#def configure_account_update_params
	#devise_parameter_sanitizer.for(:account_update) << :attribute
	#	devise_parameter_sanitizer.for(:account_update) { |u| u.permit( :username, :email, :password, :password_confirmation, :research_int, :organization, :country )}
	#end

	# The path used after sign up.
	def after_sign_up_path_for(resource)
		root_path
		#super(resource)
	end

	# The path used after sign up for inactive accounts.
	#def after_inactive_sign_up_path_for(resource)
	#	super(resource)
	#end

	private


	# Use callbacks to share common setup or constraints between actions.
	def set_user
		@user = User.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
		params.require(:user).permit(:username, :email, :role, :password, :password_confirmation, :research_int, :organization, :country)
	end
end
