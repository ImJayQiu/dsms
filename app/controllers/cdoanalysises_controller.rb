require "cdo"
require "gsl"

class CdoanalysisesController < ApplicationController


	def info
		@file = params[:dataset]
		@info = Cdo.info(input: @file)
	end

	def season
		@file = params[:dataset]
		@var_std_name = params[:var_std_name]
		@seasmin_f = Cdo.seasmin(input: @file)
		@seasmax_f = Cdo.seasmax(input: @file)
		date = Cdo.showdate(input: @seasmin_f)
		@date = date.first.split(" ").to_a
		@quarter=[]
		@date.each do |d|
			@quarter << "Q#{((d.to_date.month-1)/3 + 1)}:#{d.to_date.strftime('%Y')}".to_s
		end
		@seasmax = Cdo.info(input: @seasmax_f)
		@seasmin = Cdo.info(input: @seasmin_f)

		####### seasmin group ###############  
		@max_min = [] 
		@min_min = [] 
		@mean_min = [] 
		@seasmin.each do |i|
			@min_min << i.split(" ")[8]
			@mean_min << i.split(" ")[9] 
			@max_min << i.split(" ")[10] 
		end 
		@max_min_h = Hash[@quarter.zip(@max_min[1..-1])]
		@mean_min_h = Hash[@quarter.zip(@mean_min[1..-1])]
		@min_min_h = Hash[@quarter.zip(@min_min[1..-1])]
		####################################################

		####### seasmax group ###############  
		@max_max = [] 
		@min_max = [] 
		@mean_max = [] 
		@seasmax.each do |i|
			@min_max << i.split(" ")[8]
			@mean_max << i.split(" ")[9] 
			@max_max << i.split(" ")[10] 
		end 
		@max_max_h = Hash[@quarter.zip(@max_max[1..-1])]
		@mean_max_h = Hash[@quarter.zip(@mean_max[1..-1])]
		@min_max_h = Hash[@quarter.zip(@min_max[1..-1])]
		####################################################


	end


end
