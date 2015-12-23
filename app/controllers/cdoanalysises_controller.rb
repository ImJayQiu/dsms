#require "numru/gphys"
#require "numru/dcl"
#require "numru/ggraph"
#include NumRu

require "cdo"
#require "gsl"
require "rinruby"




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

		file = File.join(Rails.root, @dataset)
		@s_lonlat = Cdo.remapnn(lon_lat, input: file, options: '-f nc4')
		@lonlat_info = Cdo.outputtab(['date','value'],input: @s_lonlat)

		@date_set = [] 
		@value_set = [] 
		@lonlat_info.drop(1).each do |i|
			@date_set << i.split(" ")[0]
			@value_set << (i.split(" ")[1].to_f * @rate + @rate2).to_f.round(2)
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

#		@sel_file_path = File.join(Rails.root, @dataset)

#		@g_file = GPhys::NetCDF_IO.open(@sel_file_path, @var_name )

#		@lon = @g_file.axis("lon").pos.to_a 
#		@lat = @g_file.axis("lat").pos.to_a 
#		@day = @g_file.axis("time").pos.to_a 

	end



	### multi_year monthly analysis
	def mym
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@ymonmin_f = Cdo.ymonmin(input: @file)
		@ymonmin = Cdo.info(input: @ymonmin_f)
	end


	### Seasonal analysis 
	def season
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
			@min_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@mean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@max_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f
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
			@min_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@mean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@max_max << (i.split(" ")[10].to_f * @rate +@rate2).to_f
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
			@ymin_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@ymean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@ymax_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f
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
			@ymin_mean << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@ymean_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@ymax_mean << (i.split(" ")[10].to_f * @rate + @rate2).to_f
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
			@ymin_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@ymean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@ymax_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f
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
			@months << i.split(" ")[2].to_date.strftime("%B")
			@min_ymmean << (i.split(" ")[8].to_f * @rate + @rate2).to_f
			@mean_ymmean << (i.split(" ")[9].to_f * @rate + @rate2).to_f
			@max_ymmean << (i.split(" ")[10].to_f * @rate + @rate2).to_f
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

		#@ind_output = Cdo.send(@ind, [1/@rate+@rate2], input: @file, options:'-f nc4' )
		if @unit = "mm/d"
			@ind_output = Cdo.send(@ind, [1/@rate+@rate2], input: @file, options:'-f nc4' )
		else
			@ind_output = Cdo.send(@ind, input: @file, options:'-f nc4' )
		end

		@var = Cdo.showname(input: @ind_output) 
		@indice = Cdo.outputtab(['date','lon','lat','value'], input: @ind_output) 
		R.var = @var.first.split(" ").first.to_s 

		R.inds = 'cdo_'+ @ind.to_s 
		R.inds_out = 'cdo_' + @ind.to_s + '.nc' 
		R.cdocmd = 'cdo '+ @ind.to_s 

		# Selected domain file
		R.ind_output = @ind_output 
		# R.ind_output = @file 

		# Selected index image
		R.image_sel_index = Rails.root.join("public", "#{@cdo_output_path.to_s}_sel_#{@ind.to_s}.png").to_s


		#Processing Selected domain lonlat image
		R.eval "library(esd)"
		#R.eval "data_sel <- retrieve(ncfile=ind_output, param=var, type='ncdf4')"
		R.eval "data_sel <- retrieve.ncdf(ncfile=ind_output)"
		R.eval "png(filename = image_sel_index )"
		R.eval "plot(data_sel)"
		R.eval "dev.off()"

	end

end
