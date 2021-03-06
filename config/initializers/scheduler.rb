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
	time = Time.now         # catch day

	@ens.each do |ens|

		if ens == 'R1L'
			day = '01'   # catch day
		else
			day = Time.now.strftime("%d")   # catch day
		end

		ecmwf_daily_dir = "#{ecmwf_dir}/#{year}/#{month}/#{day}"

		Thread.new{

			# combined file name 
			c_file = year.to_s + month.to_s + day.to_s + ens.to_s 

			# 1.cp files of the day
			system "cp #{ecmwf_source_dir}/#{ens}#{month}#{day}* #{ecmwf_daily_dir}/#{ens}"

			# 2.rm temp files
			system "rm #{ecmwf_daily_dir}/#{ens}/*.temp"
			system "rm #{ecmwf_daily_dir}/#{ens}/*.tmp"

			# 3.merge files
			system "grib_copy #{ecmwf_daily_dir}/#{ens}/#{ens}* #{ecmwf_daily_dir}/#{ens}/#{c_file}.grib"

			# 4.grib to nc
			system "grib_to_netcdf -k 3 -o #{ecmwf_daily_dir}/#{ens}/#{c_file}.nc #{ecmwf_daily_dir}/#{ens}/#{c_file}.grib"

			# 5.extract var
			system "cdo -f nc4 splitvar #{ecmwf_daily_dir}/#{ens}/#{c_file}.nc #{ecmwf_daily_dir}/#{ens}/var"
		}
	end
end

def cp_sesame

	#source dir
	ecmwf_dir = Settings::Datasetpath.where(name: "ECMWF").first.path

	year = Time.now.year    # catch year 
	month = Time.now.strftime("%m") # catch month 
	day = Time.now.strftime("%d")   # catch day
	time = Time.now         # catch day

	ecmwf_daily_dir = "#{ecmwf_dir}/#{year}/#{month}/#{day}"

	sesame_dir = "/CLIMDATA/ECMWF/DET/SESAME/#{day}#{month}#{year}"

	source_f = "#{year}#{month}#{day}R1D" # source file name 

	des_f = "#{day}#{month}#{year}" # destination file name 

	FileUtils::mkdir_p sesame_dir unless File.directory?(sesame_dir)
	system "cp #{ecmwf_daily_dir}/R1D/#{source_f}.nc #{sesame_dir}"
	system "mv  #{sesame_dir}/#{source_f}.nc #{sesame_dir}/#{des_f}.nc"

end

def clean

	folder = Rails.root.join('public','tmp_nc')
	files = Dir["#{folder}/**/*.*"]

	files.each do |f|
		if File.mtime(f) < 4.days.ago 
			File.delete(f) 
		end 
	end
	Dir["#{folder}/**/**"].reverse_each { |d| Dir.rmdir d if (Dir.entries(d) - %w[ . .. ]).empty? }

end

#################### tasks list  ##################################################

scheduler.every '3h' do
	mkdir
end

scheduler.interval '2h' do
	ecmwf_check
	cp_sesame
end

scheduler.every '6h' do
	clean
end

scheduler.stderr = File.open('log/scheduler.log', 'ab')


