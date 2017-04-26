require "cdo"

class ObsController < ApplicationController

	def obs 
	end


	def obs_analysis

		cdo_run = Cdo.new(debug: true)

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'OBS' 
		model = params[:part3].first.to_s

		@file_name = var + '_' + mip +'_' + model + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@model_path = Settings::ObsModel.where(name: model).first.folder

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + @file_name.to_s

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

		paramater = cdo_run.showname(input: file)


		############# cut file by selected date range ##################
		@output_dir = output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}"
		sys_output_pub = Rails.root.join("public")
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		@output_file_name = output_file_name = "#{var}_#{mip}_#{model}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		@sel_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file), output: "public/#{@cdo_output_path}.nc", options:'-f nc4')
		##############################################################


		################ Data from CDO ###########################

		@dataset_infon = cdo_run.info(input: @sel_data)
		@var_name = cdo_run.showname(input: @sel_data).first.to_s
		@var_std_name = cdo_run.showstdname(input: @sel_data).first.to_s

		###########################################################

		date = cdo_run.showdate(input: @sel_data)
		@date = date.first.split(" ").to_a
		@start_date_utc = DateTime.parse(@date.first)

		#group max min mean

		@max_set = [] 
		@min_set = [] 
		@mean_set = [] 

		@dataset_infon.drop(1).each do |i|
			@min_set << i.split(" ")[8].to_f.round(3)
			@mean_set << i.split(" ")[9].to_f.round(3)
			@max_set << i.split(" ")[10].to_f.round(3)
		end 

		#		@max_h = Hash[@date.zip(@max_set)]
		#		@mean_h = Hash[@date.zip(@mean_set)]
		#		@min_h = Hash[@date.zip(@min_set)]


		@chart = LazyHighCharts::HighChart.new('graph') do |f|
			f.title(text: "Observation Data Analysis | #{model} ")
			f.xAxis(type: 'line' )
			f.yAxis [{title: {text: "#{@var_std_name.humanize} ( #{@unit} ) " }}]
			f.tooltip(borderColor: 'gray', valueSuffix: @unit )
			f.rangeSelector( selected: 4 ) 
			f.series(name: "Max", color: 'indianred', data: @max_set, pointStart: @start_date_utc, pointInterval: 1.day)
			f.series(name: "Mean", color: 'lightgreen', data: @mean_set,  pointStart: @start_date_utc, pointInterval: 1.day)
			f.series(name: "Min", color: 'lightblue', data: @min_set, pointStart: @start_date_utc, pointInterval: 1.day)
		end

		@sel_file_path = root_path+@cdo_output_path.to_s

		##### to copy cbar.gs to output folder  #################
		copy_cbar =	system("cp #{sys_output_pub}/cbar.gs #{sys_output_dir}/cbar.gs ") 
		#########################################################

		@sel_data_ctl = cdo_run.gradsdes(input: @sel_data)
		ntime = cdo_run.ntime(input: @sel_data)[0]
		stdname = cdo_run.showstdname(input: @sel_data)[0]
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
		grads_gs.puts("d ave(#{var},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title Observation #{@model_path.to_s} #{var.humanize} Mean ")
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
		grads_gs.puts("d max(#{var},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title Observation #{@model_path.to_s} #{var.humanize} Max ")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_max.png png white")
		grads_gs.puts("quit")
		grads_gs.close

		################ generate csv file ####################
		@sel_data_griddes = cdo_run.griddes(input: @sel_data)
		@gridsize = @sel_data_griddes[4].split(" ")[-1].to_i
		grads_gs = File.new("#{sys_output_dir}/#{gs_name}_csv.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{output_file_name}.ctl")
		grads_gs.puts("set t 1 last")
		grads_gs.puts("#{sys_output_pub}/fprintf.gs #{var}*#{@rate}+#{@rate2} #{output_file_name}.csv %1.2f #{@gridsize}") 
		grads_gs.puts("!sed -i /Printing/d #{var}*#{@rate}+#{@rate2} #{output_file_name}.csv")
		grads_gs.puts("quit")
		grads_gs.close


		@go_dir = "cd #{sys_output_dir.to_s}"
		@plot_mean = "grads -lbc 'exec #{gs_name}_mean.gs'"
		@plot_max = "grads -lbc 'exec #{gs_name}_max.gs'"
		@output_csv = "grads -lbc 'exec #{gs_name}_csv.gs'"
		@plot_mean_cmd = system("cd / && #{@go_dir} && #{@plot_mean} ") 
		@plot_max_cmd = system("cd / && #{@go_dir} && #{@plot_max} ") 
		#@output_csv_cmd = system("cd / && #{@go_dir} && #{@output_csv} ") 
	end

end

