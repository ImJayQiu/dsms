require "cdo"
require "gsl"

class CdoanalysisesController < ApplicationController


	def info
		@file = params[:dataset]
		@rate = params[:rate]
		@unit = params[:unit]
		@info = Cdo.info(input: @file)
	end


	### multi_year monthly analysis
	def mym
		@file = params[:dataset]
		@rate = params[:rate]
		@unit = params[:unit]
		@ymonmin_f = Cdo.ymonmin(input: @file)
		@ymonmin = Cdo.info(input: @ymonmin_f)
	end


	### Seasonal analysis 
	def season
		@file = params[:dataset]
		@rate = params[:rate]
		@unit = params[:unit]
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
			@min_min << (i.split(" ")[8] * @rate).to_i
			@mean_min << (i.split(" ")[9] * @rate).to_i
			@max_min << (i.split(" ")[10] * @rate).to_i
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
			@min_max << (i.split(" ")[8] * @rate).to_i
			@mean_max << (i.split(" ")[9] * @rate).to_i
			@max_max << (i.split(" ")[10] * @rate).to_i
		end 
		@max_max_h = Hash[@quarter.zip(@max_max[1..-1])]
		@mean_max_h = Hash[@quarter.zip(@mean_max[1..-1])]
		@min_max_h = Hash[@quarter.zip(@min_max[1..-1])]
		####################################################


	end

	def yearly
		@file = params[:dataset]
		@rate = params[:rate]
		@unit = params[:unit]
		@var_std_name = params[:var_std_name]
		@yearmin = Cdo.info(input: Cdo.yearmin(input: @file))
		@yearmax = Cdo.info(input: Cdo.yearmax(input: @file))
		@yearmean = Cdo.info(input: Cdo.yearmean(input: @file))
		@yearavg = Cdo.info(input: Cdo.yearavg(input: @file))
		@yearstd = Cdo.info(input: Cdo.yearstd(input: @file))
		@yearvar = Cdo.info(input: Cdo.yearvar(input: @file))

		################ year ########################
		@year = Cdo.showyear(input: @file).first.split(" ")
		###########################################

		####### yearly min group ###############  
		@ymax_min = [] 
		@ymin_min = [] 
		@ymean_min = [] 
		@yearmin.each do |i|
			@ymin_min << (i.split(" ")[8] * @rate).to_i
			@ymean_min << (i.split(" ")[9] * @rate).to_i
			@ymax_min << (i.split(" ")[10] * @rate).to_i
		end 
		@ymax_min_h = Hash[@year.zip(@ymax_min[1..-1])]
		@ymean_min_h = Hash[@year.zip(@ymean_min[1..-1])]
		@ymin_min_h = Hash[@year.zip(@ymin_min[1..-1])]
		####################################################

		####### yearly mean group ###############  
		@ymax_mean = [] 
		@ymin_mean = [] 
		@ymean_mean = [] 
		@yearmean.each do |i|
			@ymin_mean << (i.split(" ")[8] * @rate).to_i
			@ymean_mean << (i.split(" ")[9] * @rate).to_i
			@ymax_mean << (i.split(" ")[10] * @rate).to_i
		end 
		@ymax_mean_h = Hash[@year.zip(@ymax_mean[1..-1])]
		@ymean_mean_h = Hash[@year.zip(@ymean_mean[1..-1])]
		@ymin_mean_h = Hash[@year.zip(@ymin_mean[1..-1])]
		####################################################


		####### yearly max group ###############  
		@ymax_max = [] 
		@ymin_max = [] 
		@ymean_max = [] 
		@yearmax.each do |i|
			@ymin_max << (i.split(" ")[8] * @rate).to_i
			@ymean_max << (i.split(" ")[9] * @rate).to_i
			@ymax_max << (i.split(" ")[10] * @rate).to_i
		end 
		@ymax_max_h = Hash[@year.zip(@ymax_max[1..-1])]
		@ymean_max_h = Hash[@year.zip(@ymean_max[1..-1])]
		@ymin_max_h = Hash[@year.zip(@ymin_max[1..-1])]
		####################################################

	end

end
