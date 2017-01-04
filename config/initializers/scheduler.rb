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

	FileUtils::mkdir_p @ecmwf_daily_dir unless File.directory?(@ecmwf_daily_dir) # mkdir if folder not exist

	@ens.each do |ens|
		FileUtils::mkdir_p @ecmwf_daily_dir+"/"+ens unless File.directory?(@ecmwf_daily_dir+"/"+ens) # mkdir 
	end

end 


def ecmwf_check 

	@ens.each do |ens|

		cp_file = system("cp #{@ecmwf_source_dir}/#{ens}#{@month}#{@day}* #{@ecmwf_daily_dir}/#{ens}") 	# cp files of the day 
		rm_temp = system("rm #{@ecmwf_daily_dir}/#{ens}/*.temp") 	# rm temp files
		grib_copy = `bash -ic 'grib_copy #{@ecmwf_daily_dir}/#{ens}/#{ens}* #{@ecmwf_daily_dir}/#{ens}/all'` 	# merge files
		grib_to_netcdf = `bash -ic 'grib_to_netcdf -k 3 -o #{@ecmwf_daily_dir}/#{ens}/all.nc #{@ecmwf_daily_dir}/#{ens}/all'` 	# grib to nc
		splitvar = `bash -ic 'cdo -f nc4 splitvar #{@ecmwf_daily_dir}/#{ens}/all.nc #{@ecmwf_daily_dir}/#{ens}/var'` # extract vars

	end
end


scheduler.every '10s' do
	mkdir()
end

scheduler.every '300s' do
	ecmwf_check()
end


scheduler.stderr = File.open('log/scheduler.log', 'ab')
