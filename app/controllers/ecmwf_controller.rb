class EcmwfController < ApplicationController

	def index

	end

	def analysis 

		#cdo_run = Cdo
		cdo_run = Cdo.new(debug: true)

		################ date ##################################

		@ecmwf_dir = Settings::Datasetpath.where(name: "ECMWF").first.path
		@date = params[:date].first.to_date
		date_folder = @date.strftime("/%Y/%m/%d/").to_s

		############# Selected location  #############################

		s_lat = params[:s_lat].first.to_f
		e_lat = params[:e_lat].first.to_f
		s_lon = params[:s_lon].first.to_f
		e_lon = params[:e_lon].first.to_f

		lon_lat = "lon_#{s_lon.to_i}_#{e_lon.to_i}_lat_#{s_lat.to_i}_#{e_lat.to_i}"

		##############################################################

		############# paramaters  ################################
		var = params[:part1].first.to_s
		mip = 'ECMWF' 
		#model = params[:part3].first.to_s
		type = params[:part4].first.to_s

		###########################################

		### related file names
		@data_file = "var"+var+".nc"  
		###########################################

		### location of raw data
		folder_path = @ecmwf_dir.to_s + date_folder + type + '/' 
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

		@sel_data = cdo_run.sellonlatbox([s_lon,e_lon,s_lat,e_lat], input: data_path, output: "public/#{@cdo_output_path}")
		#########################################

		@data = cdo_run.sinfon(input: @sel_data)
		@timestamps = cdo_run.showtimestamp(input: @sel_data)

		### create 
		@ctl_file = cdo_run.gradsdes(input: @sel_data)
		#############################################

		grads_gs = File.new("public/#{@cdo_output_path}.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{lon_lat}.ctl")
		grads_gs.puts("set grads off")
		grads_gs.puts("draw title ECMWF #{type} #{var}")
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


	end


end
