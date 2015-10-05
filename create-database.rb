#!/usr/bin/env ruby
require 'rubygems'
require 'sequel'


DB = Sequel.connect('sqlite://transpo.db')

DB.execute("PRAGMA default_cache_size = 200000")
DB.execute("PRAGMA default_synchronous = OFF")
DB.execute("PRAGMA journal_mode = OFF")
DB.execute("PRAGMA temp_store = MEMORY")

#DB = Sequel.connect(:adapter=>'mysql', :socket=>'/var/run/mysqld/mysqld.sock', :database=>'transpo', :user=>'', :password=>'')

    if(DB.table_exists? :stops) then DB.drop_table :stops end
    if(DB.table_exists? :trips) then DB.drop_table :trips end
    if(DB.table_exists? :routes) then DB.drop_table :routes end
    if(DB.table_exists? :stop_times) then DB.drop_table :stop_times end


    DB.create_table :stops do
      column(:stop_id, :varchar, {:size => 5, :auto_increment => false, :unique =>true, :null => :false})
      column(:stop_name, :varchar, {:size => 50, :null => false})
      column(:stop_lat, :float, {:null => false})
      column(:stop_lon, :float, {:null => false})
      primary_key(:stop_id)
      index([:stop_id, :stop_lat, :stop_lon])
    end

    DB.create_table :trips do
      column(:trip_id, :varchar, {:size => 50, :auto_increment => false, :unique => true, :null => false})
      column(:route_id, :varchar, {:size => 40, :null => false})
      column(:service_id, :varchar, {:size => 50, :null => false})
      column(:trip_headsign, :varchar, {:size => 50})
      column(:block_id, :integer, { :null => false })
      primary_key(:trip_id)
      index([:trip_id, :route_id])
    end

    DB.create_table :routes do
      column(:route_id, :varchar, {:size => 40, :auto_increment => false, :unique => true, :null => false} )
      column(:route_short_name, :varchar, {:size => 5, :null => false})
      primary_key(:route_id)
    end

    DB.create_table :stop_times do
      column(:stop_id, :varchar, {:size => 10, :null => false})
      column(:trip_id, :varchar, {:size => 50, :null => false})
      column(:departure_time, :time, {:null => false})
      primary_key(:stop_id)
      index([:stop_id, :departure_time])
    end
