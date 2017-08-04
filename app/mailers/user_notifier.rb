class UserNotifier < ApplicationMailer

	default :from => 'cdaas@rimes.int'
	

	def send_signup_email(user)
		@user = user
		mail( :to => @user.email,
			 :subject => 'CDAAS.RIMES Sign Up' )
	end

	def send_admin_email(admin,user)
		@user = user
		@admin = admin
		admin_emails = @admin.collect(&:email).join(",")
		mail( :to => admin_emails,
			 :subject => "#{@user.username} join CDAAS.RIMES" )
	end

end
