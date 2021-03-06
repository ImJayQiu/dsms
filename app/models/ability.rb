class Ability
	include CanCan::Ability

	def initialize(user)
		# Define abilities for the passed in user here. For example:
		#
		user ||= User.new # guest user (not logged in)
		if user.role == "admin"
			can :manage, :all
			cannot :see, :description 
		end

=begin
		if user.role == "super"
			can :manage, :setting
			can :manage, :root_path
			can :manage, :analysis
			can :analyze, :cordex
			can :analyze, :nexnasa
			can :analyze, :multmodels
			can :input, :location
			can :download, :nc
			can :download, :ctl
			can :download, :csv
		end
=end

		if user.role == "expert"
			can :analyze, :cordex
			can :analyze, :nexnasa
			can :analyze, :multmodels
			can :analyze, :dataset
			can :input, :location
			can :download, :nc
			can :download, :ctl
			can :download, :csv
		end

		if user.role == "PM"
			can :analyze, :cordex
			can :analyze, :nexnasa
			can :analyze, :multmodels
			can :see, :description 
		end

		if user.role.nil?
			can :analyze, :cordex
			can :analyze, :nexnasa
			can :analyze, :multmodels
			can :see, :description 
		end


		#
		# The first argument to `can` is the action you are giving the user 
		# permission to do.
		# If you pass :manage it will apply to every action. Other common actions
		# here are :read, :create, :update and :destroy.
		#
		# The second argument is the resource the user can perform the action on. 
		# If you pass :all it will apply to every resource. Otherwise pass a Ruby
		# class of the resource.
		#
		# The third argument is an optional hash of conditions to further filter the
		# objects.
		# For example, here the user can only update published articles.
		#
		#   can :update, Article, :published => true
		#
		# See the wiki for details:
		# https://github.com/ryanb/cancan/wiki/Defining-Abilities
	end
end
