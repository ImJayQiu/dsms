class EcmwfController < ApplicationController

	def index

	end

	def analysis 
		################ date ##################################

		@date = params[:date].first.to_date
		date_folder = @date.strftime("%Y/%m/%d").to_s

		############# Selected location  #############################

		s_lat = params[:s_lat].first.to_f
		e_lat = params[:e_lat].first.to_f
		s_lon = params[:s_lon].first.to_f
		e_lon = params[:e_lon].first.to_f

		lon_lat = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		##############################################################

		############# paramaters  ################################
		var = "var40" #params[:part1].first.to_s
		mip = 'ECMWF' 
		#model = params[:part3].first.to_s
		type = params[:part4].first.to_s

		@root_file_path = Settings::Datasetpath.where(name: mip).first.path

		###########################################

		### related file names
		@data_file = var + ".128.grb" 
		###########################################

		### location of raw data
		folder_path = @root_file_path.to_s + '/' + date_folder + '/' + type + '/' 
		data_path = folder_path + @data_file.to_s
		###########################################

		### output folder and files name setting
		output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{date_folder}/#{type}/#{var}/#{lon_lat}"
		sys_output_pub = Rails.root.join("public")
		sys_output_dir = Rails.root.join("public", output_dir)

		##########################################

		### create output folder in public folder
		FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)
		##########################################

		### cut data by selected lat lon 

		@cdo_output_path = output_dir.to_s + "/" + lon_lat 

		@sel_data = Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: data_path, output: "public/#{@cdo_output_path}.grb")
		#########################################

		@data = Cdo.sinfon(input: @sel_data)
		@timestamps = Cdo.showtimestamp(input: @sel_data)

		### create 
		@ctl_file = Cdo.gradsdes(input: @sel_data)
		#############################################

		grads_gs = File.new("public/#{@cdo_output_path}.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{lon_lat}.ctl")
		grads_gs.puts("set grads off")
		grads_gs.puts("draw title This is title bla bla bla")
		grads_gs.puts("set gxout shaded")
		grads_gs.puts("set mpdset hires")
		@timestamps.first.split(" ").each_with_index do |t,i|
			grads_gs.puts("draw title This is title bla bla bla")
			grads_gs.puts("draw string 2.8 0.2 Forcasting Date: #{t} By CDAAS RIMES.INT #{Time.now.year}")
			grads_gs.puts("set t #{i+1} " )
			grads_gs.puts("d #{var}" )
			grads_gs.puts("printim #{lon_lat}-#{i+1}.png white")
			grads_gs.puts("clear")
		end
		grads_gs.puts("quit")
		grads_gs.close

		@go_dir = "cd #{sys_output_dir.to_s}"
		@plot_maps = "grads -lbc 'exec #{lon_lat}.gs'"
		@plot_maps_cmd = system("cd / && #{@go_dir} && #{@plot_maps} ") 
		@ani_maps_cmd = system("cd / && #{@go_dir} && convert -delay 100 '#{lon_lat}-%d.png[0-999]' #{lon_lat}_all.gif ") 

=begin

	  			 ##############################################################


								 @lon_r = (s_lon.to_s + "--" + e_lon.to_s).to_s
				   @lat_r = (s_lat.to_s + "--" + e_lat.to_s).to_s

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

				   ############ cut file by selected location ###################
				   #sel_lonlat = Cdo.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: file, output: sel_lonlat, options: '-f nc4')
				   ###############################################################

				   ############# cut file by selected date range ##################
				   output_dir = "tmp_nc/#{current_user.id}/#{mip}/#{model}/#{var}/#{experiment}"
				   sys_output_pub = Rails.root.join("public")
				   sys_output_dir = Rails.root.join("public", output_dir)

				   FileUtils::mkdir_p sys_output_dir.to_s unless File.directory?(sys_output_dir)

				   output_file_name = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

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
				   @sel_data_griddes = Cdo.griddes(input: @sel_data)
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
					   #@output_csv_cmd = system("cd / && #{@go_dir} && #{@output_csv} ") 
				   end
 end

=end

	end


end