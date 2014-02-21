#!/usr/env ruby
require 'fileutils'
require 'sequel'
require 'sequel/extensions/pretty_table'

class ScenarioDbSetup

  attr_accessor :db, :db_file

  def initialize(options={})
    handle_cli_options(options)
  end

  def handle_cli_options(options)
    if options[:setup]
      db_filename = 'scenario_db.sqlite3'
      if options[:testdb]
        db_filename =  'scenario_testdb.sqlite3'
      else
        db_filename = 'scenario_db.sqlite3'
      end
      configure_database(db_filename)  
      
      puts 'database setup complete.'
    end

    if !options[:add_scenario].nil? && options[:add_scenario].length == 1
      setup_database('scenario_db.sqlite3')
      open_database
      add_scenario(options[:add_scenario][0])
      if self.db[:scenarios].count > 0
        Sequel::PrettyTable.print(self.db[:scenarios])
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_scenario].nil?
      setup_database('scenario_db.sqlite3')
      open_database
      delete_scenario(options[:delete_scenario])
      if self.db[:scenarios].count > 0
        Sequel::PrettyTable.print(self.db[:scenarios])
      else
        puts 'No records to display.'
      end
    end

    if !options[:add_route].nil? && options[:add_route].length == 3
      setup_database('scenario_db.sqlite3')
      open_database
      add_route_for_scenario(options[:add_route][0], options[:add_route][1], options[:add_route][2])
      if self.db[:routes].count > 0
        Sequel::PrettyTable.print(self.db[:routes])
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_route].nil?
      setup_database('scenario_db.sqlite3')
      open_database
      delete_route(options[:delete_route])
      if self.db[:routes].count > 0
        Sequel::PrettyTable.print(self.db[:routes])
      else
        puts 'No records to display.'
      end
    end

    if !options[:add_testdata].nil? && options[:add_testdata].length == 3
      setup_database('scenario_db.sqlite3')
      open_database
      add_testdata_for_scenario(options[:add_testdata][0], options[:add_testdata][1], options[:add_testdata][2])
      if self.db[:testdata].count > 0
        Sequel::PrettyTable.print(self.db[:testdata])
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_testdata].nil?
      setup_database('scenario_db.sqlite3')
      open_database
      delete_route(options[:delete_testdata])
      if self.db[:testdata].count > 0
        Sequel::PrettyTable.print(self.db[:testdata])
      else
        puts 'No records to display.'
      end
    end

    if options[:scenarios]
      setup_database('scenario_db.sqlite3')
      open_database
      if self.db[:scenarios].count > 0
        Sequel::PrettyTable.print(self.db[:scenarios])
      else
        puts 'No records to display.'
      end
    end

    if options[:routes]
      setup_database('scenario_db.sqlite3')
      open_database
      if self.db[:routes].count > 0
        Sequel::PrettyTable.print(self.db[:routes])
      else
        puts 'No records to display.'
      end
    end

    if options[:testdata]
      setup_database('scenario_db.sqlite3')
      open_database
      if self.db[:testdata].count > 0
        Sequel::PrettyTable.print(self.db[:testdata])
      else
        puts 'No records to display.'
      end
    end
  end


  def setup_database(db_filename)
    self.db_file =  File.dirname(File.expand_path(__FILE__)) + '/data/'+db_filename

    # Create an empty database file
    if !File.exists?(self.db_file)
      puts self.db_file
      File.open(self.db_file, 'w'){}
    end
  end

  def configure_database(db_filename)
    setup_database(db_filename)
    open_database
    create_scenarios_table
    create_routes_table
    create_testdata_table 
  end 

  def open_database
    # Open the database
    self.db = Sequel.sqlite(self.db_file)
#    puts 'Loading the database file'
  end

  def create_scenarios_table
    # Create Scenarios table
    if !self.db.table_exists?(:scenarios)
#      puts "Creating the scenarios table"
      self.db.create_table :scenarios do
        primary_key :id
        String :name
        DateTime :created_at
        DateTime :updated_at
      end
    end
  end

  def add_scenario(name)
    scenarios = self.db[:scenarios]
    now = DateTime.now
    scenarios.insert(:name => name, :created_at => now, :updated_at => now)
#    puts "<#Scenario name: #{name}>"
  end

  def delete_scenario(scenario_id)
    scenarios = self.db[:scenarios]
    scenarios.filter(:id => scenario_id).delete
  end

  def reset_scenarios
    scenarios = self.db[:scenarios]
    scenarios.delete
    create_scenarios_table
  end

  def create_routes_table
    # Create the routes table
    if !self.db.table_exists?(:routes)
#      puts "Creating the routes table"
      self.db.create_table :routes do
        primary_key :id
        foreign_key :scenario_id, :scenarios, :on_delete => :cascade, :on_update => :cascade
        String :path
        String :fixture
        DateTime :created_at
        DateTime :updated_at
      end
    end
  end

  def add_route_for_scenario(path, fixture, scenario_id)
    routes = self.db[:routes]
    now = DateTime.now
    routes.insert( :scenario_id => scenario_id, :path => path, :fixture => fixture, :created_at => now, :updated_at => now)
#    puts "<scenario_id: #{scenario_id} #Path: #{path} fixture: #{fixture}>"
  end

  def delete_route(route_id)
    routes = self.db[:routes]
    routes.filter(:id => route_id).delete
  end

  def create_testdata_table
    # Create the testdata table
    if !self.db.table_exists?(:testdata)
#      puts 'Creating the testdata table'
      self.db.create_table :testdata do
        primary_key :id
        foreign_key :scenario_id, :scenarios, :on_delete => :cascade, :on_update => :cascade
        String :name
        String :value
        DateTime :created_at
        DateTime :updated_at
      end
    end
  end

  def add_testdata_for_scenario(name, value, scenario_id)
    testdata = self.db[:testdata]
    now = DateTime.now
    testdata.insert(:name=>name, :value=>value,  :scenario_id => scenario_id, :created_at => now, :updated_at => now)
#    puts "<#Name: #{name} value: #{value} scenario_id: #{scenario_id}>"
  end

  def delete_testdata_for_scenario(testdata_id)
    testdata = self.db[:testdata]
    testdata.filter(:id=>testdata_id).delete
  end

end




