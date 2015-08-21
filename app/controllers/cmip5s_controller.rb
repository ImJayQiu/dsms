require "cdo"
require "gsl"

class Cmip5sController < ApplicationController

	before_action :set_cmip5, only: [:show, :edit, :update, :destroy]

	# GET /cmip5s
	# GET /cmip5s.json

	def index
	end


	def daily_analysis

		################ date range ##################################

		@sdate = params[:s_date].first.to_date.at_beginning_of_month
		@edate = params[:e_date].first.to_date.end_of_month

		##############################################################


		############# File path and  name ################################
		var = params[:part1].first.to_s
		mip = 'day' 
		model = params[:part3].first.to_s
		experiment = params[:part4].first.to_s
		ensemble = params[:part5].first.to_s
		temporal = params[:part6].first.to_s

		@file_name = var + '_' + mip +'_' + model + '_' + experiment + '_' + ensemble + '_' + temporal + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.fullname
		@model_path = Settings::Datamodel.where(name: model).first.stdname

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + var + '/' + @experiment_path.to_s + '/' + @file_name.to_s
		##############################################################

		############# convert rate & unit ############################
		
		@variable_setting = Settings::Variable.where(name: var).first
		if @variable_setting.c_rate.blank?
			@rate = 1.to_i
			@unit = @variable_setting.unit
		else
			@rate = @variable_setting.c_rate.to_f 
			@unit = @variable_setting.c_unit
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
		@cdo_output_path = "tmp_nc/#{var}_#{mip}_#{model}_#{experiment}_#{ensemble}_#{@sdate}_#{@edate}_lon_#{s_lon}_#{e_lon}_lat_#{s_lat}_#{e_lat}.nc"

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
			@min_set << i.split(" ")[8].to_f * @rate
			@mean_set << i.split(" ")[9].to_f * @rate
			@max_set << i.split(" ")[10].to_f * @rate
		end 
		@max_h = Hash[@date.zip(@max_set)]
		@mean_h = Hash[@date.zip(@mean_set)]
		@min_h = Hash[@date.zip(@min_set)]

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
		ensemble = params[:part5].first.to_s
		temporal = params[:part6].first.to_s

		@file_name = var + '_' + mip +'_' + model + '_' + experiment + '_' + ensemble + '_' + temporal + '.nc'

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path
		@experiment_path = Settings::Experiment.where(name: experiment).first.fullname
		@model_path = Settings::Datamodel.where(name: model).first.stdname

		file = @root_file_path.to_s + '/' + @model_path.to_s + '/' + var + '/' + @experiment_path.to_s + '/' + @file_name.to_s
		##############################################################

		############# convert rate & unit ############################
		
		@variable_setting = Settings::Variable.where(name: var).first
		if @variable_setting.c_rate.blank?
			@rate = 1.to_i
			@unit = @variable_setting.unit
		else
			@rate = @variable_setting.c_rate.to_f 
			@unit = @variable_setting.c_unit
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
		@cdo_output_path = "tmp_nc/#{var}_#{mip}_#{model}_#{experiment}_#{ensemble}_#{@sdate}_#{@edate}_lon_#{s_lon}_#{e_lon}_lat_#{s_lat}_#{e_lat}.nc"

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
			@min_set << i.split(" ")[8].to_f * @rate
			@mean_set << i.split(" ")[9].to_f * @rate
			@max_set << i.split(" ")[10].to_f * @rate
		end 
		@max_h = Hash[@date.zip(@max_set)]
		@mean_h = Hash[@date.zip(@mean_set)]
		@min_h = Hash[@date.zip(@min_set)]

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
