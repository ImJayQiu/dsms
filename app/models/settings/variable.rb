class Settings::Variable < ActiveRecord::Base
	validates_uniqueness_of :name
end
