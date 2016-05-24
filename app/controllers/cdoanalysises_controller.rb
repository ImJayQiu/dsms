#require "numru/gphys"
#require "numru/dcl"
#require "numru/ggraph"
#include NumRu

require "cdo"
#require "gsl"
#require "rinruby"




class CdoanalysisesController < ApplicationController

	def lonlat
		@lon = params[:lon].to_f
		@lat = params[:lat].to_f
		lon_lat = 'lon='+@lon.to_s+'_lat='+@lat.to_s
		@var_name = params[:var_name]
		@dataset = params[:dataset]
		@file_name = params[:file_name]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]

		#	file = File.join(Rails.root, @dataset)
		@s_lonlat = Cdo.remapnn(lon_lat, input: @dataset, options: '-f nc4')
		@lonlat_info = Cdo.outputtab(['date','value'],input: @s_lonlat)

		@date_set = [] 
		@value_set = [] 
		@lonlat_info.drop(1).each do |i|
			@date_set << i.split(" ")[0]
			@value_set << (i.split(" ")[1].to_f * @rate + @rate2).to_f.round(3)
		end 
		@dv_h = Hash[@date_set.zip(@value_set)]

	end



	def info
		@var_name = params[:var_name]
		@dataset = params[:dataset]
		@file_name = params[:file_name]
		@lon_r = params[:lon_r]
		@lat_r = params[:lat_r]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@info = Cdo.info(input: @dataset)


	end



	# specific_monthly_analysis 
	def sma
		@dataset = params[:dataset]
		@cdo_output_path = params[:cdo_output_path]
		@file_name = params[:file_name]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@sdate = params[:sdate]
		@edate = params[:edate]
		@months = params[:months].values
		sel_months = @months.join(",")
		@var_std_name = Cdo.showstdname( input: @dataset)[0].to_s
		@sel_months = Cdo.selmon(sel_months, input: @dataset, output: "public/#{@cdo_output_path}_sma.nc", options:"-f nc4")

		####### Monthly Statistics ##############
		@ymonavg = Cdo.ymonavg(input: @sel_months)
		@ymon_data = Cdo.info(input: @ymonavg)

		@ymon_date = []
		@ymon_min = [] 
		@ymon_mean = [] 
		@ymon_max = [] 
		@ymon_data.drop(1).each do |i|
			@ymon_date << i.split(" ")[2].to_date.strftime('%b')
			@ymon_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymon_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymon_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@ymon_min_h = Hash[@ymon_date.zip(@ymon_min)]
		@ymon_mean_h = Hash[@ymon_date.zip(@ymon_mean)]
		@ymon_max_h = Hash[@ymon_date.zip(@ymon_max)]
		#######################
		#
		####### Yearly Average Statistics ##############
		@yyavg = Cdo.yearavg(input: @sel_months)
		@yy_avg_data = Cdo.info(input: @yyavg)
		@yy_avg_date = []
		@yy_avg_min = [] 
		@yy_avg_mean = [] 
		@yy_avg_max = [] 
		@yy_avg_data.drop(1).each do |i|
			@yy_avg_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_avg_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_avg_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_avg_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@yy_avg_min_h = Hash[@yy_avg_date.zip(@yy_avg_min)]
		@yy_avg_mean_h = Hash[@yy_avg_date.zip(@yy_avg_mean)]
		@yy_avg_max_h = Hash[@yy_avg_date.zip(@yy_avg_max)]
		#######################

		####### Yearly Max Statistics ##############
		@yymax = Cdo.yearmax(input: @sel_months)
		@yy_max_data = Cdo.info(input: @yymax)
		@yy_max_date = []
		@yy_max_min = [] 
		@yy_max_mean = [] 
		@yy_max_max = [] 
		@yy_max_data.drop(1).each do |i|
			@yy_max_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_max_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_max_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_max_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@yy_max_min_h = Hash[@yy_max_date.zip(@yy_max_min)]
		@yy_max_mean_h = Hash[@yy_max_date.zip(@yy_max_mean)]
		@yy_max_max_h = Hash[@yy_max_date.zip(@yy_max_max)]
		#######################
		#
		####### Yearly Min Statistics ##############
		@yymin = Cdo.yearmax(input: @sel_months)
		@yy_min_data = Cdo.info(input: @yymin)
		@yy_min_date = []
		@yy_min_min = [] 
		@yy_min_mean = [] 
		@yy_min_max = [] 
		@yy_min_data.drop(1).each do |i|
			@yy_min_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_min_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_min_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_min_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@yy_min_min_h = Hash[@yy_min_date.zip(@yy_min_min)]
		@yy_min_mean_h = Hash[@yy_min_date.zip(@yy_min_mean)]
		@yy_min_max_h = Hash[@yy_min_date.zip(@yy_min_max)]
		#######################


	end


	### Seasonal analysis 
	def seasonal
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
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
			@min_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
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
			@min_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_max << (i.split(" ")[10].to_f * @rate +@rate2).to_f.round(3)
		end 
		@max_max_h = Hash[@quarter.zip(@max_max[1..-1])]
		@mean_max_h = Hash[@quarter.zip(@mean_max[1..-1])]
		@min_max_h = Hash[@quarter.zip(@min_max[1..-1])]
		####################################################


	end

	def yearly
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
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
			@ymin_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
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
			@ymin_mean << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_mean << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
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
			@ymin_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@ymax_max_h = Hash[@year.zip(@ymax_max[1..-1])]
		@ymean_max_h = Hash[@year.zip(@ymean_max[1..-1])]
		@ymin_max_h = Hash[@year.zip(@ymin_max[1..-1])]
		####################################################

	end

	############### Year Monthly Mean ####################
	def ymonmean 
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@var_std_name = params[:var_std_name]
		@ymonmean_f = Cdo.ymonmean(input: @file)
		@ymonmean = Cdo.info(input: @ymonmean_f)
		####### year month mean group ###############  
		@months = [] 
		@max_ymmean = [] 
		@min_ymmean = [] 
		@mean_ymmean = [] 
		@ymonmean.drop(1).each do |i|
			#@months << i.split(" ")[2].to_date.strftime("%B")
			@months << i.split(" ")[2].to_s[5..6].to_i
			@min_ymmean << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_ymmean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_ymmean << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@max_ymmean_h = Hash[@months.zip(@max_ymmean)]
		@mean_ymmean_h = Hash[@months.zip(@mean_ymmean)]
		@min_ymmean_h = Hash[@months.zip(@min_ymmean)]
		####################################################

	end

	def indices 
		@var_name = params[:var_name]
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@ind = params[:indice].first.to_s
		@cdo_output_path = params[:cdo_output_path].to_s

		if @unit = "mm/d"
			@ind_output = Cdo.send(@ind, [1/@rate+@rate2], input: @file, options:'-f nc4' )
		else
			@ind_output = Cdo.send(@ind, input: @file, options:'-f nc4' )
		end

		@var = Cdo.showname(input: @ind_output) 
		@indice = Cdo.outputtab(['date','lon','lat','value'], input: @ind_output) 

	end

end
