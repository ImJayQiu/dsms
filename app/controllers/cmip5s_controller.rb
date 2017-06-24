#require "narray"
#require "numru/ggraph"
#require "numru/gphys"
#include NumRu

require 'thread'
require 'thwait'
require 'cdo'

#require "gsl"
#require "rinruby"

class Cmip5sController < ApplicationController

	before_action :set_cmip5, only: [:show, :edit, :update, :destroy]

	# GET /cmip5s
	# GET /cmip5s.json

	def checkfiles
		@files = Dir["/CLIMDATA/CMIP5/MONTHLY/**/*.nc"]
		@models = Settings::Datamodel.all
		@ensembles = Settings::Ensemble.all
		@exps = Settings::Experiment.all
		@vars = Settings::Variable.all
	end

	def daily 
	end

	def mult 
	end

	def daily_analysis

		cdo_run = Cdo.new(debug: true)
		#cdo_run = Cdo

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'CMIP5' 
		model = params[:part3].first.to_s
		experiment = params[:part4].first.to_s

		@file_name = var + '_day_' + model + '_' + experiment + '_' + 'rimes' + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.name
		@model_path = Settings::Datamodel.where(name: model).first.foldername

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + var + '/' + @experiment_path.to_s + '/' + @file_name.to_s
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

		############### auto map size #################################
		map_size = [360/(e_lat-s_lat),180/(e_lon-s_lon)].min.to_f
		if map_size < 1
			@map_size = 1
		else
			@map_size = map_size
		end
		################################################################

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


		paramater = cdo_run.showname(input: file)
		#paramater = Cdo.showname(input: file)

		############ cut file by selected location ###################
		#sel_lonlat = cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file, output: sel_lonlat, options: '-f nc4')
		###############################################################

		############# cut file by selected date range ##################
		@output_dir = output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}/#{experiment}"
		sys_output_pub = Rails.root.join("public")
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		@output_file_name = output_file_name = "#{var}_#{mip}_#{model}_#{experiment}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		@output_file_name = output_file_name 

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		@sel_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file), output: "public/#{@cdo_output_path}.nc", options: '-f nc4')
		##############################################################


		################ Data from CDO ###########################

		@dataset_infon = cdo_run.info(input: @sel_data)
		@var_name = cdo_run.showname(input: @sel_data).first.to_s
		@var_std_name = cdo_run.showstdname(input: @sel_data).first.to_s

		###########################################################

		date = cdo_run.showdate(input: @sel_data)
		@date = date.first.split(" ").to_a

		#group max min mean
		@start_date_utc = DateTime.parse(@date.first)
		@max_set = [] 
		@min_set = [] 
		@mean_set = [] 
		@dataset_infon.drop(1).each do |i|
			@min_set << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_set << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_set << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 


		@chart = LazyHighCharts::HighChart.new('graph') do |f|
			f.title(text: "CMIP5 DAILY Analysis | #{model} | #{experiment} ")
			f.xAxis(type: 'line' )
			f.yAxis [{title: {text: "#{@var_std_name.humanize} ( #{@unit} ) " }}]
			f.tooltip(borderColor: 'gray', valueSuffix: @unit )
			f.rangeSelector( selected: 4 ) 
			f.series(name: "Max", color: 'indianred', data: @max_set, pointStart: @start_date_utc, pointInterval: 1.day)
			f.series(name: "Mean", color: 'lightgreen', data: @mean_set,  pointStart: @start_date_utc, pointInterval: 1.day)
			f.series(name: "Min", color: 'lightblue', data: @min_set, pointStart: @start_date_utc, pointInterval: 1.day)
		end

		@sel_file_path = root_path + @cdo_output_path.to_s

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
			grads_gs.puts("set clevs 1 2 4 6 8 10 20 50 100 200 300")
			grads_gs.puts('set ccols 0 13 3 10 7 12 8 2 6 14 4')
		end

		grads_gs.puts("set mpdset hires")
		grads_gs.puts("d ave(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} Mean ")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_mean.png png white")
		grads_gs.puts("quit")
		grads_gs.close
		################### plot mean done ######################

		################### plot max start ######################

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
			grads_gs.puts("set clevs 1 10 20 30 50 75 100 150 200 250 300")
			grads_gs.puts('set ccols 0 13 3 10 7 12 8 2 6 14 4')
		end

		grads_gs.puts("set mpdset hires")
		grads_gs.puts("d max(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("cbar.gs")
		grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} Max")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_max.png png white")
		grads_gs.puts("quit")
		grads_gs.close
		################# plot max done ############################


		################### plot grid start ######################
		grads_gs = File.new("#{sys_output_dir}/#{gs_name}_grid.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{output_file_name}.ctl")
		grads_gs.puts("set grid off")
		grads_gs.puts("set gxout grid")
		grads_gs.puts("set font 1")
		grads_gs.puts("set strsiz 0.12")
		grads_gs.puts("draw string 1.8 0.1 Date Period: #{@date[0]} -- #{@date[-1]} by CDAAS RIMES.INT #{Time.now.year}")
		grads_gs.puts("d max(#{var}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} ")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_grid.png png white")
		grads_gs.puts("quit")
		grads_gs.close
		################# plot grid done ############################

		############### generate csv file ################
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
		####################### generate csv done ##################

		@go_dir = "cd #{sys_output_dir.to_s}"
		@plot_mean = "grads -lbc 'exec #{gs_name}_mean.gs'"
		@plot_max = "grads -lbc 'exec #{gs_name}_max.gs'"
		@plot_grid = "grads -lbc 'exec #{gs_name}_grid.gs'"
		@output_csv = "grads -lbc 'exec #{gs_name}_csv.gs'"
		@plot_mean_cmd = system("cd / && #{@go_dir} && #{@plot_mean} ") 
		@plot_max_cmd = system("cd / && #{@go_dir} && #{@plot_max} ") 
		@plot_grid_cmd = system("cd / && #{@go_dir} && #{@plot_grid} ") 
		if can? :download, :csv
			#	@output_csv_cmd = system("cd / && #{@go_dir} && #{@output_csv} ") 
		end
	end



	def mult_analysis

		cdo_run = Cdo.new(debug: true)

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:var].first.to_s
		mip = "mm"
		exp = params[:exp].first.to_s

		@c1 = c1 = params[:c1].first.to_s rescue nil
		@c2 = c2 = params[:c2].first.to_s rescue nil
		@c3 = c3 = params[:c3].first.to_s rescue nil
		@c4 = c4 = params[:c4].first.to_s rescue nil

		@m1 = m1 = params[:m1].first.to_s rescue nil
		@m2 = m2 = params[:m2].first.to_s rescue nil
		@m3 = m3 = params[:m3].first.to_s rescue nil
		@m4 = m4 = params[:m4].first.to_s rescue nil


		#@f1_name = var + '_' + mip +'_' + m1 + '_' + exp + '_' + 'rimes' + '.nc'
		#@f2_name = var + '_' + mip +'_' + m2 + '_' + exp + '_' + 'rimes' + '.nc'
		#@f3_name = var + '_' + mip +'_' + m3 + '_' + exp + '_' + 'rimes' + '.nc'
		#@f4_name = var + '_' + mip +'_' + m4 + '_' + exp + '_' + 'rimes' + '.nc'
		#CMIP5 file name
		#@cmip5_name = var + '_day_' + m1 + '_' + exp + '_' + 'rimes' + '.nc'
		#cordex file name
		#@cordex_name = var + '_' + exp + '_' + m1 + '_' + 'day_rimes' + '.nc'
		#nex-nasa file name
		#@nexnasa_name = var + '_day_BCSD_' + exp + '_r1i1p1_' + m1 + '_' + 'rimes' + '.nc'

		#@root_file_path = Settings::Datasetpath.where(name: mip).first.path rescue nil
		#@m1_path = Settings::Datamodel.where(name: m1).first.foldername rescue nil
		#@m2_path = Settings::Datamodel.where(name: m2).first.foldername rescue nil
		#@m3_path = Settings::Datamodel.where(name: m3).first.foldername rescue nil
		#@m4_path = Settings::Datamodel.where(name: m4).first.foldername rescue nil


		@exp_path = Settings::Experiment.where(name: exp).first.name rescue nil

		@root_f1_path = Settings::Datasetpath.where(name: c1).first.path rescue nil
		@root_f2_path = Settings::Datasetpath.where(name: c2).first.path rescue nil
		@root_f3_path = Settings::Datasetpath.where(name: c3).first.path rescue nil
		@root_f4_path = Settings::Datasetpath.where(name: c4).first.path rescue nil

=begin
		[1,2,3,4].each do |model|
			if model==1
				c=c1,m=m1,fn=@f1_name,mp=@m1_path
			elsif model==2
				c=c2,m=m2,fn=@f2_name,mp=@m2_path
			elsif model==3
				c=c3,m=m3,fn=@f3_name,mp=@m3_path
			elsif model==4
				c=c4,m=m4,fn=@f4_name,mp=@m4_path
			end

			if c == "CMIP5"
				fn = var + '_day_' + m + '_' + exp + '_' + 'rimes' + '.nc'
				mp = Settings::Datamodel.where(name: m).first.foldername rescue nil
			elsif c=="CORDEX-DAILY"
				fn = var + '_' + exp + '_' + m + '_' + 'day_rimes' + '.nc'
				mp = Settings::CordexModel.where(name: m).first.folder rescue nil
			elsif c=="NEX-NASA-DAILY"
				fn = var + '_day_BCSD_' + exp + '_r1i1p1_' + m + '_' + 'rimes' + '.nc'
				mp = Settings::NexnasaModel.where(name: m).first.folder rescue nil
			end
=end
		if c1 == "CMIP5"
			@f1_name = var + '_day_' + m1 + '_' + exp + '_' + 'rimes' + '.nc'
			@m1_path = Settings::Datamodel.where(name: m1).first.foldername rescue nil
		elsif c1=="CORDEX-DAILY"
			@f1_name = var + '_' + exp + '_' + m1 + '_' + 'day_rimes' + '.nc'
			@m1_path = Settings::CordexModel.where(name: m1).first.folder rescue nil
		elsif c1=="NEX-NASA-DAILY"
			@f1_name = var + '_day_BCSD_' + exp + '_r1i1p1_' + m1 + '_' + 'rimes' + '.nc'
			@m1_path = Settings::NexnasaModel.where(name: m1).first.folder rescue nil
		end

		if c2 == "CMIP5"
			@f2_name = var + '_day_' + m2 + '_' + exp + '_' + 'rimes' + '.nc'
			@m2_path = Settings::Datamodel.where(name: m2).first.foldername rescue nil
		elsif c2=="CORDEX-DAILY"
			@f2_name = var + '_' + exp + '_' + m2 + '_' + 'day_rimes' + '.nc'
			@m2_path = Settings::CordexModel.where(name: m2).first.folder rescue nil
		elsif c2=="NEX-NASA-DAILY"
			@f2_name = var + '_day_BCSD_' + exp + '_r1i1p1_' + m2 + '_' + 'rimes' + '.nc'
			@m2_path = Settings::NexnasaModel.where(name: m2).first.folder rescue nil
		end

		if c3 == "CMIP5"
			@f3_name = var + '_day_' + m3 + '_' + exp + '_' + 'rimes' + '.nc'
			@m3_path = Settings::Datamodel.where(name: m3).first.foldername rescue nil
		elsif c3=="CORDEX-DAILY"
			@f3_name = var + '_' + exp + '_' + m3 + '_' + 'day_rimes' + '.nc'
			@m3_path = Settings::CordexModel.where(name: m3).first.folder rescue nil
		elsif c3=="NEX-NASA-DAILY"
			@f3_name = var + '_day_BCSD_' + exp + '_r1i1p1_' + m3 + '_' + 'rimes' + '.nc'
			@m3_path = Settings::NexnasaModel.where(name: m3).first.folder rescue nil
		end

		if c4 == "CMIP5"
			@f4_name = var + '_day_' + m4 + '_' + exp + '_' + 'rimes' + '.nc'
			@m4_path = Settings::Datamodel.where(name: m4).first.foldername rescue nil
		elsif c4=="CORDEX-DAILY"
			@f4_name = var + '_' + exp + '_' + m4 + '_' + 'day_rimes' + '.nc'
			@m4_path = Settings::CordexModel.where(name: m4).first.folder rescue nil
		elsif c4=="NEX-NASA-DAILY"
			@f4_name = var + '_day_BCSD_' + exp + '_r1i1p1_' + m4 + '_' + 'rimes' + '.nc'
			@m4_path = Settings::NexnasaModel.where(name: m4).first.folder rescue nil
		end



		f1=@root_f1_path.to_s+'/'+@m1_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f1_name.to_s
		f2=@root_f2_path.to_s+'/'+@m2_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f2_name.to_s
		f3=@root_f3_path.to_s+'/'+@m3_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f3_name.to_s
		f4=@root_f4_path.to_s+'/'+@m4_path.to_s+'/'+var+'/'+@exp_path.to_s+'/'+@f4_name.to_s

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


		output_file_name = "#{var}_#{exp}_#{@sdate.strftime('%Y%m%d')}_#{@edate.strftime('%Y%m%d')}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		############# cut file by selected date range ##################
		cdo_threads=[]

		cdo_threads << Thread.new{
			@f1_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f1), output:"public/#{@cdo_output_path}_#{@c1}_#{@m1}.nc", options:'-f nc4') rescue nil  
			f1_ctl = cdo_run.gradsdes(input: @f1_data) rescue nil
		}

		cdo_threads << Thread.new{
			@f2_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f2), output:"public/#{@cdo_output_path}_#{@c2}_#{@m2}.nc", options:'-f nc4') rescue nil  
			f2_ctl = cdo_run.gradsdes(input: @f2_data) rescue nil
		}

		cdo_threads << Thread.new{
			@f3_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f3), output:"public/#{@cdo_output_path}_#{@c3}_#{@m3}.nc", options:'-f nc4') rescue nil 
			f3_ctl = cdo_run.gradsdes(input: @f3_data) rescue nil
		}

		cdo_threads << Thread.new{
			@f4_data = cdo_run.seldate([@sdate.to_datetime, @edate.to_datetime], input: cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: f4), output:"public/#{@cdo_output_path}_#{@c4}_#{@m4}.nc", options:'-f nc4') rescue nil  
			f4_ctl = cdo_run.gradsdes(input: @f4_data) rescue nil
		}

		cdo_threads.each do |ct|
			ct.join
		end
		ThreadsWait.all_waits(*cdo_threads)
		##############################################################

		[@f1_data,@f2_data,@f3_data,@f4_data].each_with_index do |data,i|
			if i+1==1
				m_title = @m1.to_s
				c_title = @c1.to_s
			elsif i+1==2
				m_title = @m2.to_s
				c_title = @c2.to_s
			elsif i+1==3
				m_title = @m3.to_s
				c_title = @c3.to_s
			elsif i+1==4
				m_title = @m4.to_s
				c_title = @c4.to_s
			end

			mdate = cdo_run.showdate(input: data) rescue nil
			date = mdate.first.split(" ").to_a rescue nil
			ntime = cdo_run.ntime(input: data)[0] rescue nil
			stdname = cdo_run.showstdname(input: data)[0] rescue nil
			gs_name_m = "lon#{s_lon.to_i}_#{e_lon.to_i}_lat#{s_lat.to_i}_#{e_lat.to_i}_#{date[0].to_date.strftime('%Y%m%d') rescue nil}_#{date[-1].to_date.strftime('%Y%m%d') rescue nil}_#{i+1}"

			grads_gs = File.new("#{sys_output_dir}/#{gs_name_m}.gs", "w")
			grads_gs.puts("reinit")
			grads_gs.puts("open #{output_file_name}_#{c_title}_#{m_title}.ctl")
			grads_gs.puts("set grads off")
			grads_gs.puts("set gxout shaded")
			grads_gs.puts("set font 1")
			grads_gs.puts("set strsiz 0.12")
			grads_gs.puts("draw string 1.8 0.1 Date Period: #{date[0]} -- #{date[-1]} by CDAAS RIMES.INT #{Time.now.year}") rescue nil 

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
			grads_gs.puts("draw title #{c_title} #{m_title} #{exp.humanize} #{stdname.humanize}") rescue nil
			grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads_#{c_title}_#{m_title}.png png white") rescue nil
			grads_gs.puts("quit")
			grads_gs.close

			@go_dir = "cd #{sys_output_dir.to_s}"

			if data.nil?
				@plot_cmd = ""
			else
				@plot_cmd = "grads -lbc 'exec #{gs_name_m}.gs'"
			end
			system("cd / && #{@go_dir} && #{@plot_cmd}") 
		end


	end


end
