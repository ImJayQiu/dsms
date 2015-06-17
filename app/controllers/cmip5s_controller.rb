require "numru/gphys"
require "numru/ggraph"
require "narray"
require "numru/dcl"
include NumRu
include GGraph
include Math

class Cmip5sController < ApplicationController

	before_action :set_cmip5, only: [:show, :edit, :update, :destroy]

	# GET /cmip5s
	# GET /cmip5s.json
	def index
	end

	def analysis

		@map_scale = params[:map_scale].first.to_i*100

		@sdate = params[:s_date].first.to_date.at_beginning_of_month
		@edate = params[:e_date].first.to_date.end_of_month

		# number of days between start date and end date 
		se_days = (@edate-@sdate).to_i

		# days a year 
		y_day = 365

		# date range
		s_days = (@sdate.strftime("%Y").to_i-1850) * y_day + @sdate.yday 
		e_days = s_days + se_days 
		r_days = s_days..e_days


		# file name
		file_name = params[:file_name].first.to_s

		# lat & lon range
		s_lat = params[:s_lat].first.to_i
		e_lat = params[:e_lat].first.to_i
		s_lon = params[:s_lon].first.to_i
		e_lon = params[:e_lon].first.to_i


		c_lon = (e_lon - s_lon)/2 + s_lon
		c_lat = (e_lat - s_lat)/2 + s_lat
		@c_point = [c_lon,c_lat]

		r_lat = s_lat..e_lat
		r_lon = s_lon..e_lon

		@area = [
			[s_lon,s_lat],
			[e_lon,s_lat],
			[e_lon,e_lat],
			[s_lon,e_lat],
			[s_lon,s_lat]
		]

		date = @sdate..@edate
		var = file_name.split('_').first.to_s
		file = NetCDF.open("public/CanCM4/#{file_name}.nc")
		
		@dataset_v = GPhys::NetCDF_IO.open(file, var).cut("lat"=>r_lat,"lon"=>r_lon, "time"=>r_days)

		@lon = @dataset_v.axis("lon").pos.to_a 

		@lat = @dataset_v.grid.axis("lat").pos.to_a 

		@time = @dataset_v.grid.axis("time").pos.to_a 

		@dataset_t = GPhys::NetCDF_IO.open(file, 'time_bnds').cut("time"=>r_days)


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
