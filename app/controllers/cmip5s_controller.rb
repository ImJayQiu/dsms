#require "narray"
#require "numru/ggraph"
require "numru/gphys"
include NumRu

require "cdo"
require "gsl"
require "rinruby"

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

	def monthly 
	end

	def daily_analysis

		################ date range ##################################

		@sdate = params[:s_date].first.to_date
		@edate = params[:e_date].first.to_date

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'day' 
		model = params[:part3].first.to_s
		experiment = params[:part4].first.to_s
		#		ensemble = params[:part5].first.to_s
		#		temporal = params[:part6].first.to_s

		@file_name = var + '_' + mip +'_' + model + '_' + experiment + '_' + 'rimes' + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.name
		@model_path = Settings::Datamodel.where(name: model).first.stdname

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
=begin
		if params[:map_size].first.blank?
			map_size = [360/(e_lat-s_lat),180/(e_lon-s_lon)].min.to_f
			if map_size < 1
				@map_size = 1
			else
				@map_size = map_size
			end
		else
			@map_size = params[:map_size].first.to_i
		end
=end
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

		paramater = Cdo.showname(input: file)

		############ cut file by selected location ###################
		sel_lonlat = Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file, output: sel_lonlat, options: '-f nc4')
		###############################################################

		############# cut file by selected date range ##################
		output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}/#{experiment}"
		sys_output_dir = Rails.root.join("public", output_dir)

		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

		output_file_name = "#{var}_#{mip}_#{model}_#{experiment}_#{@sdate}_#{@edate}_lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}.nc"
		#output_file_name = "#{var}#{mip[0]}#{model}#{experiment}#{@sdate.strftime("%Y%m%d")}#{@edate.strftime("%Y%m%d")}lo#{s_lon.to_i}_#{e_lon.to_i}la#{s_lat.to_i}_#{e_lat.to_i}.nc"

		@cdo_output_path = output_dir.to_s + "/" + output_file_name

		#@cdo_output_path = output_dir.to_s + "/#{var}_#{mip}_#{model}_#{experiment}_#{@sdate}_#{@edate}_lon_#{s_lon}_#{e_lon}_lat_#{s_lat}_#{e_lat}.nc"

		@sel_data = Cdo.seldate([@sdate.to_datetime, @edate.to_datetime], input: sel_lonlat, output: "public/#{@cdo_output_path}", options:'-f nc4')
		##############################################################

		################ Data from GPhys ###########################
		#		@sel_data_path = File.join(Rails.root, @sel_data)
		#		@dataset_g = GPhys::NetCDF_IO.open(@sel_data_path, var)

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
			@min_set << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(2)
			@mean_set << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(2)
			@max_set << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(2)
		end 
		@max_h = Hash[@date.zip(@max_set)]
		@mean_h = Hash[@date.zip(@mean_set)]
		@min_h = Hash[@date.zip(@min_set)]
		@sel_file_path = root_path+@cdo_output_path.to_s

		################ R esd ploting ####################
		R.var = var.to_s

		# RIMES domain file
		R.file_rimes = file 
		R.img_title = model.upcase + ' | ' + experiment.upcase + ' | ' + var.humanize + ' | Daily: ' + @sdate.to_s + ' -- ' + @edate.to_s 
		#	R.sub_title = 'Latitude: ' + s_lat.to_s + ' -- ' + e_lat.to_s + ' | '  + 'Longitude: ' + s_lon.to_s + ' -- ' + e_lon.to_s  


		# RIMES image size 
		R.img_h = ( e_lat.to_f - s_lat.to_f ).abs*50
		R.img_w = ( e_lon.to_f - s_lon.to_f ).abs*50
		R.img_res = 300.to_s

		# RIMES domain lonlat image
		R.image_rimes_lonlat = Rails.root.join("public", "#{@cdo_output_path.to_s}_rimes_lonlat.png").to_s

		# RIMES domain sphere image
		R.image_rimes_sphere = Rails.root.join("public", "#{@cdo_output_path.to_s}_rimes_sphere.png").to_s

=begin
		#Processing RIMES domain lonlat image
		R.eval "library(esd)"
		R.eval "data_rimes <- retrieve.ncdf(ncfile = file_rimes, param = var)"
		R.eval "png(filename=image_rimes_lonlat, units='px', width = 800, height = 600, res = 100, te)"
		R.eval "map(data_rimes, projection='lonlat')"
		R.eval "dev.off()"

		#Processing RIMES domain sphere image
		R.eval "library(esd)"
		R.eval "data_rimes <- retrieve.ncdf(ncfile = file_rimes, param = var)"
		R.eval "png(filename=image_rimes_sphere)"
		R.eval "map(data_rimes, projection='sphere')"
		R.eval "dev.off()"
=end

		# Selected domain file
		R.file_sel = Rails.root.join("public", "#{@cdo_output_path.to_s}").to_s
		# Selected lonlat image
		R.image_sel_lonlat = Rails.root.join("public", "#{@cdo_output_path.to_s}_sel_lonlat.png").to_s

		# Selected sphere image
		R.image_sel_sphere = Rails.root.join("public", "#{@cdo_output_path.to_s}_sel_sphere.png").to_s

		#Processing Selected domain lonlat image
		R.eval "library(esd)"
		R.eval "data_sel <- retrieve.ncdf(ncfile = file_sel, param = var)"
		R.eval "png(filename = image_sel_lonlat, units='px', width = img_w, height = img_h, res = img_res )"
		R.eval "map(data_sel, projection='lonlat', main=img_title)"
		R.eval "dev.off()"

		#Processing Selected domain sphere image
		R.eval "library(esd)"
		R.eval "data_sel <- retrieve.ncdf(ncfile = file_sel, param = var)"
		R.eval "png(filename = image_sel_sphere)"
		R.eval "map(data_sel, projection='sphere')"
		R.eval "dev.off()"

		############ Parameters for GrADS ctl file #################
		@griddes = Cdo.griddes(input: @sel_data).to_a
		std_name = Cdo.showstdname(input: @sel_data)[0].humanize
		levels = Cdo.showlevel(input: @sel_data)
		nlevel = Cdo.nlevel(input: @sel_data)[0]
		ntime = Cdo.ntime(input: @sel_data)[0]
		xsize = @griddes[12].split(" ")[2].to_s
		ysize = @griddes[13].split(" ")[2].to_s
		xinc = @griddes[15].split(" ")[2].to_s

		############## Generate ctl file for GrADS ###############
		grads_ctl = File.new("public/#{@cdo_output_path}.ctl", "w")
		grads_ctl.puts("DSET ^#{output_file_name} ")
		grads_ctl.puts("TITLE Reading GCM Cut Datasets")
		grads_ctl.puts("DTYPE netcdf")
		grads_ctl.puts("UNDEF 1.e+20f")
		grads_ctl.puts("OPTIONS template")
		grads_ctl.puts("XDEF #{xsize} LINEAR #{s_lon.to_s} #{xinc} ")
		grads_ctl.puts("YDEF #{ysize} LINEAR #{s_lat.to_s} #{xinc}")
		grads_ctl.puts("TDEF #{ntime.to_s} LINEAR 0Z01JAN2006 1DY")
		grads_ctl.puts("ZDEF #{nlevel.to_s} Levels #{levels.to_s}")
		grads_ctl.puts("VARS 1")
		grads_ctl.puts("#{var} 0 t,y,x #{std_name} (#{o_unit.to_s})")
		grads_ctl.puts("ENDVARS")
		grads_ctl.close

		gs_name = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"
		grads_gs = File.new("#{sys_output_dir}/#{gs_name}.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{output_file_name}.ctl")
		grads_gs.puts("set t 200")
		grads_gs.puts("set grads off")
		grads_gs.puts("set gxout shaded")
		grads_gs.puts("set mpdset hires")
		grads_gs.puts("set clevs 0 1 2 3 4 5 6 7 8 9 10")
		#	grads_gs.puts("set ccols 0 14 20 25 30 40 50 60")
		grads_gs.puts("d ave(#{var},t=1,t=#{ntime.to_s})")
		#	grads_gs.puts("d pr*86400")
		# grads_gs.puts("cbar")
		grads_gs.puts("draw title RIMES")
		grads_gs.puts("printim #{output_file_name}_sel_lonlat_grads.png png white")
		grads_gs.puts("quit")
		grads_gs.close

		@go_dir = "cd #{sys_output_dir.to_s}"
		@plot_cmd = "grads -lbc 'exec #{gs_name}.gs'"
		@plot = system("cd / && #{@go_dir} && #{@plot_cmd} ") 
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
		@model_path = Settings::Datamodel.where(name: model).first.stdname

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

		############### auto map size #################################
=begin
		if params[:map_size].first.blank?
			map_size = [360/(e_lat-s_lat),180/(e_lon-s_lon)].min.to_f
			if map_size < 1
				@map_size = 1
			else
				@map_size = map_size
			end
		else
			@map_size = params[:map_size].first.to_i
		end
=end
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


	# GET /cmip5s/1
	# GET /cmip5s/1.json
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
