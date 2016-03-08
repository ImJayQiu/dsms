require "thread"
require 'thwait'
require "cdo"

class CordexController < ApplicationController




	def daily 
	end

	def monthly 
	end

	def daily_analysis

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'CORDEX-DAILY' 
		model = params[:part3].first.to_s
		experiment = params[:part4].first.to_s

		@file_name = var + '_' + experiment + '_' + model + '_' + 'day_rimes' + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.name
		@model_path = Settings::CordexModel.where(name: model).first.folder

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + @experiment_path.to_s + '/' + var +'/' + @file_name.to_s
		##############################################################

		############# convert rate & unit ############################
		@variable_setting = Settings::Variable.where(name: var).first
		o_unit = @variable_setting.unit
		if @variable_setting.c_rate.blank?
			@rate = 1.to_i
			@rate2 = 0.to_i 
			@unit = o_unit
		else
			if @variable_setting.unit == "K" && @variable_setting.c_unit == "°C"
				@rate = 1.to_i
				@rate2 = @variable_setting.c_rate.to_f 
				@unit = @variable_setting.c_unit
			else
				@rate = @variable_setting.c_rate.to_f 
				@rate2 = 0.to_i 
				@unit = @variable_setting.c_unit
			end
		end

		############# Selected location  #############################

		s_lat = params[:s_lat].first.to_f
		e_lat = params[:e_lat].first.to_f
		s_lon = params[:s_lon].first.to_f
		e_lon = params[:e_lon].first.to_f

		@lon_r = (s_lon.to_s + "--" + e_lon.to_s).to_s
		@lat_r = (s_lat.to_s + "--" + e_lat.to_s).to_s


		################ range of lon & lat ###########################
		r_lat = s_lat..e_lat
		r_lon = s_lon..e_lon

		@area = [
			[s_lon,s_lat],
			[e_lon,s_lat],
			[e_lon,e_lat],
			[s_lon,e_lat],
			[s_lon,s_lat]
		]
		############################################################

		#################### date period ###########################

		days = @sdate..@edate

		#################### CDO operations  #########################

		paramater = Cdo.showname(input: file)

		############# cut file by selected date range ##################
		output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}/#{experiment}"
		sys_output_pub = Rails.root.join("public")
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		output_file_name = "#{var}_#{mip}_#{model}_#{experiment}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		@sel_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file), output: "public/#{@cdo_output_path}.nc", options:'-f nc4')
		##############################################################


		################ Data from CDO ###########################

		@dataset_infon = Cdo.info(input: @sel_data)
		@var_name = Cdo.showname(input: @sel_data).first.to_s
		@var_std_name = Cdo.showstdname(input: @sel_data).first.to_s

		###########################################################

		date = Cdo.showdate(input: @sel_data)
		@date = date.first.split(" ").to_a

		#group max min mean
		@max_set = [] 
		@min_set = [] 
		@mean_set = [] 
		@dataset_infon.drop(1).each do |i|
			@min_set << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_set << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_set << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@max_h = Hash[@date.zip(@max_set)]
		@mean_h = Hash[@date.zip(@mean_set)]
		@min_h = Hash[@date.zip(@min_set)]
		@sel_file_path = root_path+@cdo_output_path.to_s

		##### to copy cbar.gs to output folder  #################
		copy_cbar =	system("cp #{sys_output_pub}/cbar.gs #{sys_output_dir}/cbar.gs ") 
		#########################################################

		@sel_data_ctl = Cdo.gradsdes(input: @sel_data)
		ntime = Cdo.ntime(input: @sel_data)[0]
		stdname = Cdo.showstdname(input: @sel_data)[0]
		gs_name = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}"

		grads_gs = File.new("#{sys_output_dir}/#{gs_name}_mean.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{output_file_name}.ctl")
		grads_gs.puts("set grads off")
		grads_gs.puts("set gxout shaded")
		grads_gs.puts("set font 1")
		grads_gs.puts("set strsiz 0.12")
		grads_gs.puts("draw string 1.8 0.1 Date Period: #{@date[0]} -- #{@date[-1]} by CDAAS RIMES.INT #{Time.now.year}")

		if @unit == "°C"
			grads_gs.puts('set rgb 33 248 50 60')
			grads_gs.puts('set rgb 34 255 50 89')
			grads_gs.puts('set rgb 35 255 50 185')
			grads_gs.puts('set rgb 36 248 50 255')
			grads_gs.puts('set rgb 37 224 50 255')
			grads_gs.puts('set rgb 38 195 50 255')
			grads_gs.puts('set rgb 39 175 50 255')
			grads_gs.puts('set rgb 40 161 50 255')
			grads_gs.puts('set rgb 41 137 50 255')
			grads_gs.puts('set rgb 42 118 74 255')
			grads_gs.puts('set rgb 43 98 74 255')
			grads_gs.puts('set rgb 44 79 50 255')
			grads_gs.puts('set rgb 45 50 50 255')
			grads_gs.puts('set rgb 46 50 74 255')
			grads_gs.puts('set rgb 47 50 89 255')
			grads_gs.puts('set rgb 48 50 113 255')
			grads_gs.puts('set rgb 49 50 146 255')
			grads_gs.puts('set rgb 50 50 175 255')
			grads_gs.puts('set rgb 51 50 204 255')
			grads_gs.puts('set rgb 52 50 224 255')
			grads_gs.puts('set rgb 53 50 255 253')
			grads_gs.puts('set rgb 54 50 255 228')
			grads_gs.puts('set rgb 55 50 255 200')
			grads_gs.puts('set rgb 56 50 255 161')
			grads_gs.puts('set rgb 57 50 255 132')
			grads_gs.puts('set rgb 58 50 255 103')
			grads_gs.puts('set rgb 59 50 255 79')
			grads_gs.puts('set rgb 60 50 255 60')
			grads_gs.puts('set rgb 61 79 255 50')
			grads_gs.puts('set rgb 62 132 255 50')
			grads_gs.puts('set rgb 63 171 255 50')
			grads_gs.puts('set rgb 64 204 255 50')
			grads_gs.puts('set rgb 65 224 255 50')
			grads_gs.puts('set rgb 66 253 255 50')
			grads_gs.puts('set rgb 67 255 233 50')
			grads_gs.puts('set rgb 68 255 224 50')
			grads_gs.puts('set rgb 69 255 209 50')
			grads_gs.puts('set rgb 70 255 204 50')
			grads_gs.puts('set rgb 71 255 185 50')
			grads_gs.puts('set rgb 72 255 161 50')
			grads_gs.puts('set rgb 73 255 146 50')
			grads_gs.puts('set rgb 74 255 127 50')
			grads_gs.puts('set rgb 75 255 118 50')
			grads_gs.puts('set rgb 76 255 93 50')
			grads_gs.puts('set rgb 77 255 74 50')
			grads_gs.puts('set rgb 78 255 60 50')
			grads_gs.puts('set rgb 79 255 33 33')
			grads_gs.puts('set rgb 80 255 0 0')
			grads_gs.puts('set rgb 81 235 10 0')
			grads_gs.puts('set rgb 82 215 20 0')
			grads_gs.puts('set rgb 83 195 30 0')
			grads_gs.puts('set rgb 84 175 40 0')
			grads_gs.puts('set rgb 85 165 45 0')
			grads_gs.puts('set rgb 86 155 50 0')
			grads_gs.puts('set rgb 87 145 55 0')
			grads_gs.puts('set rgb 88 135 60 0')
			grads_gs.puts('set rgb 89 120 60 0')
			grads_gs.puts('set rgb 90 100 60 0')
			grads_gs.puts('set rgb 91 80 60 0')
			grads_gs.puts('set rgb 20 250 240 230')
			grads_gs.puts('set rgb 21 240 220 210')
			grads_gs.puts('set rgb 22 225 190 180')
			grads_gs.puts('set rgb 23 200 160 150')
			grads_gs.puts('set rgb 24 180 140 130')
			grads_gs.puts('set rgb 25 160 120 110')
			grads_gs.puts('set rgb 26 140 100 90')
			grads_gs.puts("set clevs -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 ")
			grads_gs.puts('set ccols 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 85 87 88 89 90 91 26 25 24 23 22 21 20')
		elsif @unit == "mm/d"
			grads_gs.puts("set clevs 0 2 4 6 8 10 20 50 100 200 300")
			grads_gs.puts('set ccols 0 13 3 10 7 12 8 2 6 14 4')
		end

		grads_gs.puts("set mpdset hires")
		grads_gs.puts("d ave(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} Mean ")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_mean.png png white")
		grads_gs.puts("quit")
		grads_gs.close


		grads_gs = File.new("#{sys_output_dir}/#{gs_name}_max.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{output_file_name}.ctl")
		grads_gs.puts("set grads off")
		grads_gs.puts("set gxout shaded")
		grads_gs.puts("set font 1")
		grads_gs.puts("set strsiz 0.12")
		grads_gs.puts("draw string 1.8 0.1 Date Period: #{@date[0]} -- #{@date[-1]} by CDAAS RIMES.INT #{Time.now.year}")

		if @unit == "°C"
			grads_gs.puts('set rgb 33 248 50 60')
			grads_gs.puts('set rgb 34 255 50 89')
			grads_gs.puts('set rgb 35 255 50 185')
			grads_gs.puts('set rgb 36 248 50 255')
			grads_gs.puts('set rgb 37 224 50 255')
			grads_gs.puts('set rgb 38 195 50 255')
			grads_gs.puts('set rgb 39 175 50 255')
			grads_gs.puts('set rgb 40 161 50 255')
			grads_gs.puts('set rgb 41 137 50 255')
			grads_gs.puts('set rgb 42 118 74 255')
			grads_gs.puts('set rgb 43 98 74 255')
			grads_gs.puts('set rgb 44 79 50 255')
			grads_gs.puts('set rgb 45 50 50 255')
			grads_gs.puts('set rgb 46 50 74 255')
			grads_gs.puts('set rgb 47 50 89 255')
			grads_gs.puts('set rgb 48 50 113 255')
			grads_gs.puts('set rgb 49 50 146 255')
			grads_gs.puts('set rgb 50 50 175 255')
			grads_gs.puts('set rgb 51 50 204 255')
			grads_gs.puts('set rgb 52 50 224 255')
			grads_gs.puts('set rgb 53 50 255 253')
			grads_gs.puts('set rgb 54 50 255 228')
			grads_gs.puts('set rgb 55 50 255 200')
			grads_gs.puts('set rgb 56 50 255 161')
			grads_gs.puts('set rgb 57 50 255 132')
			grads_gs.puts('set rgb 58 50 255 103')
			grads_gs.puts('set rgb 59 50 255 79')
			grads_gs.puts('set rgb 60 50 255 60')
			grads_gs.puts('set rgb 61 79 255 50')
			grads_gs.puts('set rgb 62 132 255 50')
			grads_gs.puts('set rgb 63 171 255 50')
			grads_gs.puts('set rgb 64 204 255 50')
			grads_gs.puts('set rgb 65 224 255 50')
			grads_gs.puts('set rgb 66 253 255 50')
			grads_gs.puts('set rgb 67 255 233 50')
			grads_gs.puts('set rgb 68 255 224 50')
			grads_gs.puts('set rgb 69 255 209 50')
			grads_gs.puts('set rgb 70 255 204 50')
			grads_gs.puts('set rgb 71 255 185 50')
			grads_gs.puts('set rgb 72 255 161 50')
			grads_gs.puts('set rgb 73 255 146 50')
			grads_gs.puts('set rgb 74 255 127 50')
			grads_gs.puts('set rgb 75 255 118 50')
			grads_gs.puts('set rgb 76 255 93 50')
			grads_gs.puts('set rgb 77 255 74 50')
			grads_gs.puts('set rgb 78 255 60 50')
			grads_gs.puts('set rgb 79 255 33 33')
			grads_gs.puts('set rgb 80 255 0 0')
			grads_gs.puts('set rgb 81 235 10 0')
			grads_gs.puts('set rgb 82 215 20 0')
			grads_gs.puts('set rgb 83 195 30 0')
			grads_gs.puts('set rgb 84 175 40 0')
			grads_gs.puts('set rgb 85 165 45 0')
			grads_gs.puts('set rgb 86 155 50 0')
			grads_gs.puts('set rgb 87 145 55 0')
			grads_gs.puts('set rgb 88 135 60 0')
			grads_gs.puts('set rgb 89 120 60 0')
			grads_gs.puts('set rgb 90 100 60 0')
			grads_gs.puts('set rgb 91 80 60 0')
			grads_gs.puts('set rgb 20 250 240 230')
			grads_gs.puts('set rgb 21 240 220 210')
			grads_gs.puts('set rgb 22 225 190 180')
			grads_gs.puts('set rgb 23 200 160 150')
			grads_gs.puts('set rgb 24 180 140 130')
			grads_gs.puts('set rgb 25 160 120 110')
			grads_gs.puts('set rgb 26 140 100 90')
			grads_gs.puts("set clevs -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 ")
			grads_gs.puts('set ccols 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 85 87 88 89 90 91 26 25 24 23 22 21 20')
		elsif @unit == "mm/d"
			grads_gs.puts("set clevs 0 10 20 30 50 75 100 150 200 250 300")
			grads_gs.puts('set ccols 0 13 3 10 7 12 8 2 6 14 4')
		end

		grads_gs.puts("set mpdset hires")
		grads_gs.puts("d max(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} Max")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_max.png png white")
		grads_gs.puts("quit")
		grads_gs.close

		@go_dir = "cd #{sys_output_dir.to_s}"
		@plot_mean = "grads -lbc 'exec #{gs_name}_mean.gs'"
		@plot_max = "grads -lbc 'exec #{gs_name}_max.gs'"
		@plot_mean_cmd = system("cd / && #{@go_dir} && #{@plot_mean} ") 
		@plot_max_cmd = system("cd / && #{@go_dir} && #{@plot_max} ") 
	end






	def monthly_analysis

		################ date range ##################################

		@sdate = params[:s_date].first.to_date.at_beginning_of_month
		@edate = params[:e_date].first.to_date.end_of_month

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'Amon' 
		model = params[:part3].first.to_s
		experiment = params[:part4].first.to_s
		#		ensemble = params[:part5].first.to_s
		#		temporal = params[:part6].first.to_s

		@file_name = var + '_' + mip +'_' + model + '_' + experiment + '_' + 'rimes' + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.name
		@model_path = Settings::Datamodel.where(name: model).first.foldername

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + var + '/' + @experiment_path.to_s + '/' + @file_name.to_s
		##############################################################


		############# convert rate & unit ############################

		@variable_setting = Settings::Variable.where(name: var).first
		if @variable_setting.c_rate.blank?
			@rate = 1.to_i
			@rate2 = 0.to_i 
			@unit = @variable_setting.unit
		else
			if @variable_setting.unit == "K" && @variable_setting.c_unit == "°C"
				@rate = 1.to_i
				@rate2 = @variable_setting.c_rate.to_f 
				@unit = @variable_setting.c_unit
			else
				@rate = @variable_setting.c_rate.to_f 
				@rate2 = 0.to_i 
				@unit = @variable_setting.c_unit
			end
		end

		############# Selected location  #############################

		s_lat = params[:s_lat].first.to_f
		e_lat = params[:e_lat].first.to_f
		s_lon = params[:s_lon].first.to_f
		e_lon = params[:e_lon].first.to_f

		@lon_r = (s_lon.to_s + "--" + e_lon.to_s).to_s
		@lat_r = (s_lat.to_s + "--" + e_lat.to_s).to_s


		################## find centre point ###########################
		c_lon = (e_lon - s_lon)/2 + s_lon
		c_lat = (e_lat - s_lat)/2 + s_lat
		@c_point = [c_lon,c_lat]
		##############################################################

		################ range of lon & lat ###########################
		r_lat = s_lat..e_lat
		r_lon = s_lon..e_lon

		@area = [
			[s_lon,s_lat],
			[e_lon,s_lat],
			[e_lon,e_lat],
			[s_lon,e_lat],
			[s_lon,s_lat]
		]
		############################################################

		#################### date period ###########################

		days = @sdate..@edate

		#################### CDO operations  #########################

		paramater = Cdo.showname(input: file)

		############ cut file by selected location ###################
		sel_lonlat = Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file, output: sel_lonlat, options: '-f nc4')
		###############################################################

		############# cut file by selected date range ##################
		output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}/#{experiment}"
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		@cdo_output_path = output_dir.to_s + "/#{var}_#{mip}_#{model}_#{experiment}_#{@sdate}_#{@edate}_lon_#{s_lon}_#{e_lon}_lat_#{s_lat}_#{e_lat}.nc"

		@sel_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: sel_lonlat, output: "public/#{@cdo_output_path}", options:'-f nc4')
		##############################################################

		@dataset_infon = Cdo.info(input: @sel_data)
		@var_name = Cdo.showname(input: @sel_data).first.to_s
		@var_std_name = Cdo.showstdname(input: @sel_data).first.to_s

		###########################################################

		date = Cdo.showdate(input: @sel_data)
		@date = date.first.split(" ").to_a
		#group max min mean
		@max_set = [] 
		@min_set = [] 
		@mean_set = [] 
		@dataset_infon.drop(1).each do |i|
			@min_set << (i.split(" ")[8].to_f * @rate + @rate2.to_f).to_f.round(2)
			@mean_set << (i.split(" ")[9].to_f * @rate + @rate2.to_f).to_f.round(2)
			@max_set << (i.split(" ")[10].to_f * @rate + @rate2.to_f).to_f.round(2)
		end 
		@max_h = Hash[@date.zip(@max_set)]
		@mean_h = Hash[@date.zip(@mean_set)]
		@min_h = Hash[@date.zip(@min_set)]

		@sel_file_path = root_path+@cdo_output_path.to_s

		################ R esd ploting ####################
		R.var = var.to_s

		# Selected domain file
		#R.file_sel = Rails.root.join("public", "#{@cdo_output_path.to_s}").to_s
		R.file_sel = sel_lonlat 

		# Selected lonlat image
		R.image_sel_lonlat = Rails.root.join("public", "#{@cdo_output_path.to_s}_sel_lonlat.png").to_s

		# Selected sphere image
		R.image_sel_sphere = Rails.root.join("public", "#{@cdo_output_path.to_s}_sel_sphere.png").to_s

		#Processing Selected domain lonlat image
		R.eval "library(esd)"
		R.eval "data_sel <- retrieve.ncdf(ncfile = file_sel, param = var)"
		R.eval "png(filename=image_sel_lonlat)"
		R.eval "map(data_sel, projection='lonlat')"
		R.eval "dev.off()"

		#Processing Selected domain sphere image
		R.eval "library(esd)"
		R.eval "data_sel <- retrieve.ncdf(ncfile = file_sel, param = var)"
		R.eval "png(filename=image_sel_sphere)"
		R.eval "map(data_sel, projection='sphere')"
		R.eval "dev.off()"


		# RIMES domain file
		R.file_rimes = file 

		# RIMES domain lonlat image
		R.image_rimes_lonlat = Rails.root.join("public", "#{@cdo_output_path.to_s}_rimes_lonlat.png").to_s
		# RIMES domain sphere image
		R.image_rimes_sphere = Rails.root.join("public", "#{@cdo_output_path.to_s}_rimes_sphere.png").to_s

		#Processing RIMES domain lonlat image
		R.eval "library(esd)"
		R.eval "data_rimes <- retrieve.ncdf(ncfile = file_rimes, param = var)"
		R.eval "png(filename=image_rimes_lonlat)"
		R.eval "map(data_rimes, projection='lonlat')"
		R.eval "dev.off()"

		#Processing RIMES domain sphere image
		R.eval "library(esd)"
		R.eval "data_rimes <- retrieve.ncdf(ncfile = file_rimes, param = var)"
		R.eval "png(filename=image_rimes_sphere)"
		R.eval "map(data_rimes, projection='sphere')"
		R.eval "dev.off()"
		##########################################################
	end

	def mult_analysis

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:var].first.to_s
		mip = params[:mip].first.to_s
		@m1 = m1 = params[:m1].first.to_s
		@m2 = m2 = params[:m2].first.to_s
		@m3 = m3 = params[:m3].first.to_s
		@m4 = m4 = params[:m4].first.to_s
		exp = params[:exp].first.to_s

		@f1_name = var + '_' + mip +'_' + m1 + '_' + exp + '_' + 'rimes' + '.nc'
		@f2_name = var + '_' + mip +'_' + m2 + '_' + exp + '_' + 'rimes' + '.nc'
		@f3_name = var + '_' + mip +'_' + m3 + '_' + exp + '_' + 'rimes' + '.nc'
		@f4_name = var + '_' + mip +'_' + m4 + '_' + exp + '_' + 'rimes' + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path rescue nil
		@exp_path = Settings::Experiment.where(name: exp).first.name rescue nil
		@m1_path = Settings::Datamodel.where(name: m1).first.foldername rescue nil
		@m2_path = Settings::Datamodel.where(name: m2).first.foldername rescue nil
		@m3_path = Settings::Datamodel.where(name: m3).first.foldername rescue nil
		@m4_path = Settings::Datamodel.where(name: m4).first.foldername rescue nil

		f1=@root_file_path.to_s+'/'+@m1_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f1_name.to_s
		f2=@root_file_path.to_s+'/'+@m2_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f2_name.to_s
		f3=@root_file_path.to_s+'/'+@m3_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f3_name.to_s
		f4=@root_file_path.to_s+'/'+@m4_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f4_name.to_s
		##############################################################
		#
		############# convert rate & unit ############################
		@variable_setting = Settings::Variable.where(name: var).first rescue nil
		o_unit = @variable_setting.unit rescue nil
		if @variable_setting.c_rate.blank? 
			@rate = 1.to_i
			@rate2 = 0.to_i 
			@unit = o_unit
		else
			if @variable_setting.unit == "K" && @variable_setting.c_unit == "°C"
				@rate = 1.to_i
				@rate2 = @variable_setting.c_rate.to_f 
				@unit = @variable_setting.c_unit
			else
				@rate = @variable_setting.c_rate.to_f 
				@rate2 = 0.to_i 
				@unit = @variable_setting.c_unit
			end
		end

		##############################################################
		#
		############# Selected location  #############################

		s_lat = params[:s_lat].first.to_f
		e_lat = params[:e_lat].first.to_f
		s_lon = params[:s_lon].first.to_f
		e_lon = params[:e_lon].first.to_f

		@lon_r = (s_lon.to_s + "--" + e_lon.to_s).to_s
		@lat_r = (s_lat.to_s + "--" + e_lat.to_s).to_s

		################################################################
		#
		###############################################################

		output_dir = "tmp_m_nc/#{current_user.id}/#{mip}/#{var}/#{exp}"
		sys_output_pub = Rails.root.join("public")
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		##### to copy cbar.gs to output folder  #################
		copy_cbar = system("cp #{sys_output_pub}/cbar.gs #{sys_output_dir}/cbar.gs ") 
		#########################################################


		output_file_name = "#{var}_#{mip}_#{exp}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		############# cut file by selected date range ##################
		cdo_threads=[]

		cdo_threads << Thread.new{
			@f1_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f1), output:"public/#{@cdo_output_path}_#{m1}.nc", options:'-f nc4') rescue nil  
			f1_ctl = Cdo.gradsdes(input: @f1_data, output: f1_ctl, options:'-f ctl') rescue nil
		}

		cdo_threads << Thread.new{
			@f2_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f2), output:"public/#{@cdo_output_path}_#{m2}.nc", options:'-f nc4') rescue nil  
			f2_ctl = Cdo.gradsdes(input: @f2_data, output: f2_ctl, options:'-f ctl') rescue nil
		}

		cdo_threads << Thread.new{
			@f3_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f3), output:"public/#{@cdo_output_path}_#{m3}.nc", options:'-f nc4') rescue nil 
			f3_ctl = Cdo.gradsdes(input: @f3_data, output: f3_ctl, options:'-f ctl') rescue nil
		}

		cdo_threads << Thread.new{
			@f4_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f4), output:"public/#{@cdo_output_path}_#{m4}.nc", options:'-f nc4') rescue nil  
			f4_ctl = Cdo.gradsdes(input: @f4_data, output: f4_ctl, options:'-f ctl') rescue nil
		}

		cdo_threads.each do |ct|
			ct.join
		end
		ThreadsWait.all_waits(*cdo_threads)
		##############################################################
		gs_name = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}"

		[@f1_data,@f2_data,@f3_data,@f4_data].each_with_index do |data,i|
			if i+1==1
				m_name = m1
				m_title = @m1_path.to_s
			elsif i+1==2
				m_name = m2
				m_title = @m2_path.to_s
			elsif i+1==3
				m_name = m3
				m_title = @m3_path.to_s
			elsif i+1==4
				m_name = m4
				m_title = @m4_path.to_s
			end
			ntime = Cdo.ntime(input: data)[0] rescue nil
			stdname = Cdo.showstdname(input: data)[0] rescue nil
			#data_ctl = Cdo.gradsdes(input: data) rescue nil
			gs_name_m = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_#{i+1}"

			grads_gs = File.new("#{sys_output_dir}/#{gs_name_m}.gs", "w")
			grads_gs.puts("reinit")
			grads_gs.puts("open #{output_file_name}_#{m_name}.ctl")
			grads_gs.puts("set grads off")
			grads_gs.puts("set gxout shaded")
			grads_gs.puts("set font 1")
			grads_gs.puts("set strsiz 0.12")
			grads_gs.puts("draw string 1.8 0.1 Date Period: #{@sdate.strftime('%Y-%m-%d')} -- #{@edate.strftime('%Y-%m-%d')} by CDAAS RIMES.INT #{Time.now.year}")

			if @unit == "°C"
				grads_gs.puts('set rgb 33 248 50 60')
				grads_gs.puts('set rgb 34 255 50 89')
				grads_gs.puts('set rgb 35 255 50 185')
				grads_gs.puts('set rgb 36 248 50 255')
				grads_gs.puts('set rgb 37 224 50 255')
				grads_gs.puts('set rgb 38 195 50 255')
				grads_gs.puts('set rgb 39 175 50 255')
				grads_gs.puts('set rgb 40 161 50 255')
				grads_gs.puts('set rgb 41 137 50 255')
				grads_gs.puts('set rgb 42 118 74 255')
				grads_gs.puts('set rgb 43 98 74 255')
				grads_gs.puts('set rgb 44 79 50 255')
				grads_gs.puts('set rgb 45 50 50 255')
				grads_gs.puts('set rgb 46 50 74 255')
				grads_gs.puts('set rgb 47 50 89 255')
				grads_gs.puts('set rgb 48 50 113 255')
				grads_gs.puts('set rgb 49 50 146 255')
				grads_gs.puts('set rgb 50 50 175 255')
				grads_gs.puts('set rgb 51 50 204 255')
				grads_gs.puts('set rgb 52 50 224 255')
				grads_gs.puts('set rgb 53 50 255 253')
				grads_gs.puts('set rgb 54 50 255 228')
				grads_gs.puts('set rgb 55 50 255 200')
				grads_gs.puts('set rgb 56 50 255 161')
				grads_gs.puts('set rgb 57 50 255 132')
				grads_gs.puts('set rgb 58 50 255 103')
				grads_gs.puts('set rgb 59 50 255 79')
				grads_gs.puts('set rgb 60 50 255 60')
				grads_gs.puts('set rgb 61 79 255 50')
				grads_gs.puts('set rgb 62 132 255 50')
				grads_gs.puts('set rgb 63 171 255 50')
				grads_gs.puts('set rgb 64 204 255 50')
				grads_gs.puts('set rgb 65 224 255 50')
				grads_gs.puts('set rgb 66 253 255 50')
				grads_gs.puts('set rgb 67 255 233 50')
				grads_gs.puts('set rgb 68 255 224 50')
				grads_gs.puts('set rgb 69 255 209 50')
				grads_gs.puts('set rgb 70 255 204 50')
				grads_gs.puts('set rgb 71 255 185 50')
				grads_gs.puts('set rgb 72 255 161 50')
				grads_gs.puts('set rgb 73 255 146 50')
				grads_gs.puts('set rgb 74 255 127 50')
				grads_gs.puts('set rgb 75 255 118 50')
				grads_gs.puts('set rgb 76 255 93 50')
				grads_gs.puts('set rgb 77 255 74 50')
				grads_gs.puts('set rgb 78 255 60 50')
				grads_gs.puts('set rgb 79 255 33 33')
				grads_gs.puts('set rgb 80 255 0 0')
				grads_gs.puts('set rgb 81 235 10 0')
				grads_gs.puts('set rgb 82 215 20 0')
				grads_gs.puts('set rgb 83 195 30 0')
				grads_gs.puts('set rgb 84 175 40 0')
				grads_gs.puts('set rgb 85 165 45 0')
				grads_gs.puts('set rgb 86 155 50 0')
				grads_gs.puts('set rgb 87 145 55 0')
				grads_gs.puts('set rgb 88 135 60 0')
				grads_gs.puts('set rgb 89 120 60 0')
				grads_gs.puts('set rgb 90 100 60 0')
				grads_gs.puts('set rgb 91 80 60 0')
				grads_gs.puts('set rgb 20 250 240 230')
				grads_gs.puts('set rgb 21 240 220 210')
				grads_gs.puts('set rgb 22 225 190 180')
				grads_gs.puts('set rgb 23 200 160 150')
				grads_gs.puts('set rgb 24 180 140 130')
				grads_gs.puts('set rgb 25 160 120 110')
				grads_gs.puts('set rgb 26 140 100 90')
				grads_gs.puts('set clevs -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35')
				grads_gs.puts('set ccols 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 85 87 88 89 90 91 26 25 24 23 22 21 20')
			elsif @unit == "mm/d"
				grads_gs.puts("set clevs 0 2 4 6 8 10 20 50 100 200 300")
				grads_gs.puts('set ccols 0 13 3 10 7 12 8 2 6 14 4')
			end
			grads_gs.puts("set mpdset hires")
			grads_gs.puts("d ave(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
			grads_gs.puts("cbar.gs")
			grads_gs.puts("draw title #{m_title} Daily #{exp.humanize} #{stdname.humanize}") rescue nil
			grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_#{i+1}.png png white") rescue nil
			grads_gs.puts("quit")
			grads_gs.close
		end

		@go_dir = "cd #{sys_output_dir.to_s}"

		if @f1_data.nil?
			@plot_m1_cmd = ""
		else
			@plot_m1_cmd = "grads -lbc 'exec #{gs_name}_1.gs'"
		end

		if @f2_data.nil?
			@plot_m2_cmd = ""
		else
			@plot_m2_cmd = "grads -lbc 'exec #{gs_name}_2.gs'"
		end

		if @f3_data.nil?
			@plot_m3_cmd = ""
		else
			@plot_m3_cmd = "grads -lbc 'exec #{gs_name}_3.gs'"
		end

		if @f4_data.nil?
			@plot_m4_cmd = ""
		else
			@plot_m4_cmd = "grads -lbc 'exec #{gs_name}_4.gs'"
		end

		system("cd / && #{@go_dir} && #{@plot_m1_cmd}") 
		system("cd / && #{@go_dir} && #{@plot_m2_cmd}") 
		system("cd / && #{@go_dir} && #{@plot_m3_cmd}") 
		system("cd / && #{@go_dir} && #{@plot_m4_cmd}") 


	end


	# GET /cmip5s/1
	# GET /cmip5s/1.json
	#
	def show
	end

	# GET /cmip5s/new
	def new
		@cmip5 = Cmip5.new
	end

	# GET /cmip5s/1/edit
	def edit
	end

	# POST /cmip5s
	# POST /cmip5s.json
	def create
		@cmip5 = Cmip5.new(cmip5_params)

		respond_to do |format|
			if @cmip5.save
				format.html { redirect_to @cmip5, notice: 'Cmip5 was successfully created.' }
				format.json { render :show, status: :created, location: @cmip5 }
			else
				format.html { render :new }
				format.json { render json: @cmip5.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /cmip5s/1
	# PATCH/PUT /cmip5s/1.json
	def update
		respond_to do |format|
			if @cmip5.update(cmip5_params)
				format.html { redirect_to @cmip5, notice: 'Cmip5 was successfully updated.' }
				format.json { render :show, status: :ok, location: @cmip5 }
			else
				format.html { render :edit }
				format.json { render json: @cmip5.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /cmip5s/1
	# DELETE /cmip5s/1.json
	def destroy
		@cmip5.destroy
		respond_to do |format|
			format.html { redirect_to cmip5s_url, notice: 'Cmip5 was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_cmip5
		@cmip5 = Cmip5.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def cmip5_params
		params[:cmip5]
	end
end
