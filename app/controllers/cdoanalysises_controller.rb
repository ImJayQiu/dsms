#require "numru/gphys"
#require "numru/dcl"
#require "numru/ggraph"
#include NumRu

require "cdo"
require "zip"
#require "gsl"
#require "rinruby"




class CdoanalysisesController < ApplicationController

	def lonlat
		cdo_run = Cdo.new(debug: true)
		@lon = params[:lon].to_f
		@lat = params[:lat].to_f
		lon_lat = 'lon='+@lon.to_s+'_lat='+@lat.to_s
		@var_name = params[:var_name]
		@dataset = params[:dataset]
		@file_name = params[:file_name]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]

		@s_lonlat = cdo_run.remapnn(lon_lat, input: @dataset, options: '-f nc4')
		@lonlat_info = cdo_run.outputtab(['date','value'],input: @s_lonlat)
		@var_std_name = cdo_run.showstdname( input: @dataset)[0].to_s

		@date_set = [] 
		@value_set = [] 
		@lonlat_info.drop(1).each do |i|
			@date_set << i.split(" ")[0]
			@value_set << (i.split(" ")[1].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart = LazyHighCharts::HighChart.new('graph') do |f|
			f.title(text: "Analysis | #{@lon},#{@lat} ")
			f.subtitle(text: "#{@file_name}")
			f.xAxis(categories: @date_set )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Value", color: 'lightblue', data: @value_set)
		end

	end



	def info
		cdo_run = Cdo.new(debug: true)
		@var_name = params[:var_name]
		@dataset = params[:dataset]
		@file_name = params[:file_name]
		@lon_r = params[:lon_r]
		@lat_r = params[:lat_r]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@info = cdo_run.info(input: @dataset)
	end


	def ecmwf_level 
		@level = params[:level].first.to_i

		cdo_run = Cdo.new(debug: true)
		
		@sys_output_dir = params[:sys_output_dir]
		@cdaas_output_dir = params[:cdaas_output_dir]
		@output_name = params[:output_name]
		
		@dataset = params[:dataset]
		@lon_r = params[:lon_r]
		@lat_r = params[:lat_r]
		@unit = cdo_run.showunit(input: @dataset).first.to_s
		@sellevel = cdo_run.sellevel(@level, input: @dataset, output: @sys_output_dir + @output_name + "_L#{@level}.nc", options: "-f nc4")
		@go_dir = "cd #{@sys_output_dir.to_s}"
		@print_csv_cmd = system("cd / && #{@go_dir} && cdo outputtab,date,time,lon,lat,value #{@sellevel} > #{@output_name}_L#{@level}.csv ") 
	
	end

	# specific_monthly_analysis 
	def sma
		cdo_run = Cdo.new(debug: true)
		@dataset = params[:dataset]
		@cdo_output_path = params[:cdo_output_path]
		@file_name = params[:file_name]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@sdate = params[:sdate]
		@edate = params[:edate]
		@months = params[:months].values
		sel_months = @months.join(",")
		@var_std_name = cdo_run.showstdname( input: @dataset)[0].to_s
		@sel_months = cdo_run.selmon(sel_months, input: @dataset, output: "public/#{@cdo_output_path}_sma.nc", options:"-f nc4")

		@sel_data_ctl = cdo_run.gradsdes(input: @sel_months)

		####### Monthly Statistics ##############
		@ymonavg = cdo_run.ymonavg(input: @sel_months)
		@ymon_data = cdo_run.info(input: @ymonavg)

		@ymon_date = []
		@ymon_min = [] 
		@ymon_mean = [] 
		@ymon_max = [] 
		@ymon_data.drop(1).each do |i|
			@ymon_date << i.split(" ")[2].to_date.strftime('%b')
			@ymon_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymon_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymon_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_ymon = LazyHighCharts::HighChart.new('ymon') do |f|
			f.title(text: "Monthly Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit} | #{@sdate.to_date.strftime('%Y-%m-%d')}--#{@edate.to_date.strftime('%Y-%m-%d')}")
			f.xAxis(categories: @ymon_date )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @ymon_max)
			f.series(name: "Mean", color: 'lightgreen', data: @ymon_mean)
			f.series(name: "Min", color: 'indianred', data: @ymon_min)
		end

		#######################
		#
		####### Yearly Average Statistics ##############
		@yyavg = cdo_run.yearavg(input: @sel_months)
		@yy_avg_data = cdo_run.info(input: @yyavg)
		@yy_avg_date = []
		@yy_avg_min = [] 
		@yy_avg_mean = [] 
		@yy_avg_max = [] 
		@yy_avg_data.drop(1).each do |i|
			@yy_avg_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_avg_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_avg_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_avg_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_yy_avg = LazyHighCharts::HighChart.new('yy_avg') do |f|
			f.title(text: "Yearly Average Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit} | #{@sdate.to_date.strftime('%Y-%m-%d')}--#{@edate.to_date.strftime('%Y-%m-%d')}")
			f.xAxis(categories: @yy_avg_date )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @yy_avg_max)
			f.series(name: "Mean", color: 'lightgreen', data: @yy_avg_mean)
			f.series(name: "Min", color: 'indianred', data: @yy_avg_min)
		end
		#######################

		####### Yearly Max Statistics ##############
		@yymax = cdo_run.yearmax(input: @sel_months)
		@yy_max_data = cdo_run.info(input: @yymax)
		@yy_max_date = []
		@yy_max_min = [] 
		@yy_max_mean = [] 
		@yy_max_max = [] 
		@yy_max_data.drop(1).each do |i|
			@yy_max_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_max_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_max_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_max_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_yy_max = LazyHighCharts::HighChart.new('yy_max') do |f|
			f.title(text: "Yearly Maximum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit} | #{@sdate.to_date.strftime('%Y-%m-%d')}--#{@edate.to_date.strftime('%Y-%m-%d')}")
			f.xAxis(categories: @yy_max_date )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @yy_max_max)
			f.series(name: "Mean", color: 'lightgreen', data: @yy_max_mean)
			f.series(name: "Min", color: 'indianred', data: @yy_max_min)
		end
		#######################
		#
		####### Yearly Min Statistics ##############
		@yymin = cdo_run.yearmin(input: @sel_months)
		@yy_min_data = cdo_run.info(input: @yymin)
		@yy_min_date = []
		@yy_min_min = [] 
		@yy_min_mean = [] 
		@yy_min_max = [] 
		@yy_min_data.drop(1).each do |i|
			@yy_min_date << i.split(" ")[2].to_date.strftime('%Y')
			@yy_min_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@yy_min_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@yy_min_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_yy_min = LazyHighCharts::HighChart.new('yy_min') do |f|
			f.title(text: "Yearly Minimum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit} | #{@sdate.to_date.strftime('%Y-%m-%d')}--#{@edate.to_date.strftime('%Y-%m-%d')}")
			f.xAxis(categories: @yy_min_date )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @yy_min_max)
			f.series(name: "Mean", color: 'lightgreen', data: @yy_min_mean)
			f.series(name: "Min", color: 'indianred', data: @yy_min_min)
		end
		#######################


	end


	### Seasonal analysis 
	def seasonal
		cdo_run = Cdo.new(debug: true)
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@var_std_name = params[:var_std_name]
		@seasmin_f = cdo_run.seasmin(input: @file)
		@seasmax_f = cdo_run.seasmax(input: @file)
		date = cdo_run.showdate(input: @seasmin_f)
		@date = date.first.split(" ").to_a
		@quarter=[]
		@date.each do |d|
			@quarter << "Q#{((d.to_date.month-1)/3 + 1)}:#{d.to_date.strftime('%Y')}".to_s
		end
		@seasmax = cdo_run.info(input: @seasmax_f)
		@seasmin = cdo_run.info(input: @seasmin_f)

		####### seasmin group ###############  
		@max_min = [] 
		@min_min = [] 
		@mean_min = [] 
		@seasmin.each do |i|
			@min_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_s_min = LazyHighCharts::HighChart.new('s_min') do |f|
			f.title(text: "Seasonal Minimum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @quarter )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @max_min)
			f.series(name: "Mean", color: 'lightgreen', data: @mean_min)
			f.series(name: "Min", color: 'indianred', data: @min_min)
		end
		####################################################

		####### seasmax group ###############  
		@max_max = [] 
		@min_max = [] 
		@mean_max = [] 
		@seasmax.each do |i|
			@min_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_max << (i.split(" ")[10].to_f * @rate +@rate2).to_f.round(3)
		end 

		@chart_s_max = LazyHighCharts::HighChart.new('s_max') do |f|
			f.title(text: "Seasonal Maximum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @quarter )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @max_max)
			f.series(name: "Mean", color: 'lightgreen', data: @mean_max)
			f.series(name: "Min", color: 'indianred', data: @min_max)
		end
		####################################################

	end

	def yearly
		cdo_run = Cdo.new(debug: true)
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@var_std_name = params[:var_std_name]
		@yearmin = cdo_run.info(input: cdo_run.yearmin(input: @file))
		@yearmax = cdo_run.info(input: cdo_run.yearmax(input: @file))
		@yearmean = cdo_run.info(input: cdo_run.yearmean(input: @file))
		@yearavg = cdo_run.info(input: cdo_run.yearavg(input: @file))
		@yearstd = cdo_run.info(input: cdo_run.yearstd(input: @file))
		@yearvar = cdo_run.info(input: cdo_run.yearvar(input: @file))

		################ year ########################
		@year = cdo_run.showyear(input: @file).first.split(" ")
		###########################################

		####### yearly min group ###############  
		@ymax_min = [] 
		@ymin_min = [] 
		@ymean_min = [] 
		@yearmin.each do |i|
			@ymin_min << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_min << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_min << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_y_min = LazyHighCharts::HighChart.new('y_min') do |f|
			f.title(text: "Yearly Minimum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @year )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @ymax_min)
			f.series(name: "Mean", color: 'lightgreen', data: @ymean_min)
			f.series(name: "Min", color: 'indianred', data: @ymin_min)
		end
		####################################################

		####### yearly mean group ###############  
		@ymax_mean = [] 
		@ymin_mean = [] 
		@ymean_mean = [] 
		@yearmean.each do |i|
			@ymin_mean << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_mean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_mean << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_y_mean = LazyHighCharts::HighChart.new('y_mean') do |f|
			f.title(text: "Yearly Average Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @year )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @ymax_mean)
			f.series(name: "Mean", color: 'lightgreen', data: @ymean_mean)
			f.series(name: "Min", color: 'indianred', data: @ymin_mean)
		end
		####################################################


		####### yearly max group ###############  
		@ymax_max = [] 
		@ymin_max = [] 
		@ymean_max = [] 
		@yearmax.each do |i|
			@ymin_max << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@ymean_max << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@ymax_max << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 
		@ymax_max_h = Hash[@year.zip(@ymax_max[1..-1])]
		@ymean_max_h = Hash[@year.zip(@ymean_max[1..-1])]
		@ymin_max_h = Hash[@year.zip(@ymin_max[1..-1])]

		@chart_y_max = LazyHighCharts::HighChart.new('y_max') do |f|
			f.title(text: "Yearly Maximum Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @year )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @ymax_max)
			f.series(name: "Mean", color: 'lightgreen', data: @ymean_max)
			f.series(name: "Min", color: 'indianred', data: @ymin_max)
		end
		####################################################

	end

	############### Year Monthly Mean ####################
	def ymonmean 
		cdo_run = Cdo.new(debug: true)
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@var_std_name = params[:var_std_name]
		@ymonmean_f = cdo_run.ymonmean(input: @file)
		@ymonmean = cdo_run.info(input: @ymonmean_f)
		####### year month mean group ###############  
		@months = [] 
		@max_ymmean = [] 
		@min_ymmean = [] 
		@mean_ymmean = [] 
		@ymonmean.drop(1).each do |i|
			#@months << i.split(" ")[2].to_date.strftime("%B")
			@months << i.split(" ")[2].to_s[5..6].to_i
			@min_ymmean << (i.split(" ")[8].to_f * @rate + @rate2).to_f.round(3)
			@mean_ymmean << (i.split(" ")[9].to_f * @rate + @rate2).to_f.round(3)
			@max_ymmean << (i.split(" ")[10].to_f * @rate + @rate2).to_f.round(3)
		end 

		@chart_ymm = LazyHighCharts::HighChart.new('ymm') do |f|
			f.title(text: "Year-Monthly Average Data Analysis")
			f.subtitle(text: "#{@var_std_name.humanize} | Unit: #{@unit}")
			f.xAxis(categories: @months )
			f.tooltip(valueSuffix: @unit )
			f.yAxis [{title: {text: @var_std_name.to_s }}]
			f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', borderWidth: 0)
			f.series(name: "Max", color: 'lightblue', data: @max_ymmean)
			f.series(name: "Mean", color: 'lightgreen', data: @mean_ymmean)
			f.series(name: "Min", color: 'indianred', data: @min_ymmean)
		end
		####################################################

	end

	def indices 
		cdo_run = Cdo.new(debug: true)
		@var_name = params[:var_name]
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@ind = params[:indice].first.to_s
		@cdo_output_path = params[:cdo_output_path].to_s

		if @unit = "mm/d"
			@ind_output = cdo_run.send(@ind, [1/@rate+@rate2], input: @file, options:'-f nc4' )
		else
			@ind_output = cdo_run.send(@ind, input: @file, options:'-f nc4' )
		end

		@var = cdo_run.showname(input: @ind_output) 
		@indice = cdo_run.outputtab(['date','lon','lat','value'], input: @ind_output) 

	end

	def shape
		cdo_run = Cdo.new(debug: true)
		@shape_zip = params[:shape]
		@var_name = params[:var_name]
		@file = params[:dataset]
		@rate = params[:rate].to_f
		@rate2 = params[:rate2].to_f
		@unit = params[:unit]
		@cdo_output_path = params[:cdo_output_path].to_s
		@output_dir = params[:output_dir].to_s
		@output_file_name = params[:output_file_name].to_s


		####### extract zip files and find shp file #######################
		@shape_name=[]
		Zip::File.open(@shape_zip.tempfile.to_path) do |zip_file|
			zip_file.each do |entry|
				@shape_dir = 'public/' + @output_dir + '/'
				@shape_name << entry.name.to_s
				entry.extract(@shape_dir + entry.name) unless File.exist?(@shape_dir + entry.name)
			end
		end
		@shp_file = @shape_name.select {|s|s.include? '.shp'}

		ntime = cdo_run.ntime(input: @file)[0]
		############### generate csv file ################
		grads_gs = File.new("public/#{@output_dir}/upload_shape.gs", "w")
		grads_gs.puts("reinit")
		grads_gs.puts("open #{@output_file_name}.ctl")
		#grads_gs.puts("set t 1 last")
		grads_gs.puts("set grads off")
		grads_gs.puts("set gxout shaded")
		grads_gs.puts("set font 1")
		grads_gs.puts("set strsiz 0.12")
		grads_gs.puts("draw string 1.8 0.1 by CDAAS @ RIMES.INT #{Time.now.year}")

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
		grads_gs.puts("set mpdraw off")
		grads_gs.puts("d ave(#{@var_name}*#{@rate}+#{@rate2},t=1,t=#{ntime.to_s})")
		grads_gs.puts("draw shp #{@shp_file.first}")
		grads_gs.puts("cbar.gs")
		#grads_gs.puts("draw title #{@model_path.to_s} Daily #{experiment.humanize} #{stdname.humanize} Mean with shapefile ")
		grads_gs.puts("printim #{@output_file_name}_shape.png png white")
		grads_gs.puts("quit")
		grads_gs.close

		####################### generate csv done ##################
		sys_output_dir = Rails.root.join("public", @output_dir.to_s)
		@go_dir = "cd #{sys_output_dir.to_s}"
		@shape_png = "grads -lbc 'exec upload_shape.gs'"
		@shape_cmd = system("cd / && #{@go_dir} && #{@shape_png} ") 

	end

end
