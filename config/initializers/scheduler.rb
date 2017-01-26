require 'thread'
require 'thwait'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.s


#@ens = ["R2D", "R2Y"] different levtype

@ens = ['R1D', 'R1E', 'R1H', 'R1L', 'R2P', 'R2U', 'R2D', 'R2Y']


def mkdir

	ecmwf_dir = Settings::Datasetpath.where(name: "ECMWF").first.path

	year = Time.now.year    # catch year 
	month = Time.now.strftime("%m") # catch month 
	day = Time.now.strftime("%d")   # catch day
	time = Time.now         # catch day
	ecmwf_daily_dir = "#{ecmwf_dir}/#{year}/#{month}/#{day}"


	# mkdir if folder not exist
	FileUtils::mkdir_p ecmwf_daily_dir unless File.directory?(ecmwf_daily_dir)

	# mkdir 
	@ens.each do |ens|
		FileUtils::mkdir_p ecmwf_daily_dir + "/" + ens unless File.directory?(ecmwf_daily_dir + "/" + ens)
	end

end

def ecmwf_check

	#### The original files location ##########
	ecmwf_source_dir = Settings::Datasetpath.where(name: "ECMWF").first.source
	
	#### Where CDAAS normalize and save the files
	ecmwf_dir = Settings::Datasetpath.where(name: "ECMWF").first.path

	year = Time.now.year    # catch year 
	month = Time.now.strftime("%m") # catch month 
	day = Time.now.strftime("%d")   # catch day
	time = Time.now         # catch day
	ecmwf_daily_dir = "#{ecmwf_dir}/#{year}/#{month}/#{day}"

	@ens.each do |ens|
		Thread.new{
			# 1.cp files of the day
			system "cp #{ecmwf_source_dir}/#{ens}#{month}#{day}* #{ecmwf_daily_dir}/#{ens}"

			# 2.rm temp files
			system "rm #{ecmwf_daily_dir}/#{ens}/*.temp"

			# 3.merge files
			system "grib_copy #{ecmwf_daily_dir}/#{ens}/#{ens}* #{ecmwf_daily_dir}/#{ens}/all.grib"

			# 4.grib to nc
			system "grib_to_netcdf -k 3 -o #{ecmwf_daily_dir}/#{ens}/all.nc #{ecmwf_daily_dir}/#{ens}/all.grib"

			# 5.extract var
			system "cdo -f nc4 splitvar #{ecmwf_daily_dir}/#{ens}/all.nc #{ecmwf_daily_dir}/#{ens}/var"
		}
	end
end


scheduler.every '20s' do
	mkdir
end


scheduler.every '60m' do
	ecmwf_check
end


scheduler.stderr = File.open('log/scheduler.log', 'ab')


