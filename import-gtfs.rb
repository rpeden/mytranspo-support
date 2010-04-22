#!/usr/bin/env ruby
require 'rubygems'
require 'csv'
require 'sequel'
require 'benchmark'




DB = Sequel.connect(:adapter=>'mysql', :socket=>'/var/run/mysqld/mysqld.sock', :database=>'transpo', :user=>'', :password=>'')

#populate stops table
elapsed = Benchmark.realtime do

    stops = DB[:stops]
    DB.transaction do
        puts("working on stops")
    
	CSV.foreach("stops.txt", :headers => true) do |row|
	      
	stops.insert(:stop_id => row['stop_id'], :stop_name => row['stop_name'], :stop_lat => row['stop_lat'], :stop_lon => row['stop_lon'])
	# puts "#{row['stop_name']} record inserted."
		
	end
    end #end transaction
    #populate trips table
    
    trips = DB[:trips]
    puts("working on trips")
    
    DB.transaction do
    
	CSV.foreach("trips.txt", :headers => true) do |row|
		  
	    trips.insert(:trip_id => row['trip_id'], :service_id => row['service_id'], :route_id => row['route_id'], :trip_headsign => row['trip_headsign'], \
			      :block_id => row['block_id'])
	     #puts "#{row['trip_headsign']} record inserted."
	end
    end #end transaction
    #populate routes table
    
    routes = DB[:routes]
    puts("working on routes")
    
    DB.transaction do
    
	CSV.foreach("routes.txt", :headers => true) do |row|
      
	    routes.insert(:route_id => row['route_id'], :route_short_name => row['route_short_name'])
      
	    #puts("Route #{row['route_short_name']} inserted.")
    
	end
    end #end transaction
    #populate stop times table
    
    stop_times = DB[:stop_times]
    puts("working on stop times")
    after_midnight = /[2][4-9]:[0-9][0-9]:[0][0]/
    
    DB.transaction do
	    
	CSV.foreach("stop_times.txt", :headers => true) do |row|
	 dep_time = row['departure_time']
	    
	    if(dep_time.match(after_midnight)) 
		dep_time.sub!(/\A24/, '00')
		dep_time.sub!(/\A25/, '01')
		dep_time.sub!(/\A26/, '02')
		dep_time.sub!(/\A27/, '03')
		dep_time.sub!(/\A28/, '04')
		dep_time.sub!(/\A29/, '05')
	    end	#end if
	    
	    stop_times.insert(:trip_id => row['trip_id'], :departure_time => row['departure_time'], :stop_id => row['stop_id'])
    
        end
    end #end transaction

end #end benchmark
elapsed_minutes = elapsed / 60
puts("completed in #{elapsed_minutes} minutes")




