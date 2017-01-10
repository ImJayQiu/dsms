require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton

@year = Time.now.year 	# catch year 
@month = Time.now.strftime("%m") # catch month 
@day = Time.now.strftime("%d") 	# catch day
@time = Time.now 	# catch day
@ecmwf_source_dir = Settings::Datasetpath.where(name: "ECMWF").first.source
@ecmwf_dir = Settings::Datasetpath.where(name: "ECMWF").first.path
@ecmwf_daily_dir = "#{@ecmwf_dir}/#{@year}/#{@month}/#{@day}"
@ens = ["R1D", "R1E", "R1H", "R1L", "R2D", "R2P", "R2U", "R2Y"]


def mkdir

	# mkdir if folder not exist
	FileUtils::mkdir_p @ecmwf_daily_dir unless File.directory?(@ecmwf_daily_dir) 

	# mkdir 
	@ens.each do |ens|
		FileUtils::mkdir_p @ecmwf_daily_dir+"/"+ens unless File.directory?(@ecmwf_daily_dir+"/"+ens) 
	end

end 


def ecmwf_check 

	# 1.cp files of the day
	@ens.to_a.each do |ens|
		%x[cp #{@ecmwf_source_dir}/#{ens}#{@month}#{@day}* #{@ecmwf_daily_dir}/#{ens}] 
	end

	# 2.rm temp files
	@ens.to_a.each do |ens|
		%x[rm #{@ecmwf_daily_dir}/#{ens}/*.temp]	
	end

	# 3.merge files
	@ens.to_a.each do |ens|
		%x[bash -ic 'grib_copy #{@ecmwf_daily_dir}/#{ens}/#{ens}* #{@ecmwf_daily_dir}/#{ens}/all'] 	
	end

	# 4.grib to nc
	@ens.to_a.each do |ens|
		%x[bash -ic 'grib_to_netcdf -k 3 -o #{@ecmwf_daily_dir}/#{ens}/all.nc #{@ecmwf_daily_dir}/#{ens}/all']
	end

	# 5.extract var
	@ens.to_a.each do |ens|
		%x[bash -ic 'cdo -f nc4 splitvar #{@ecmwf_daily_dir}/#{ens}/all.nc #{@ecmwf_daily_dir}/#{ens}/var']
	end

end


scheduler.every '1000s' do
	mkdir()
end

scheduler.every '300s' do
	ecmwf_check()
end


scheduler.stderr = File.open('log/scheduler.log', 'ab')
