#!/usr/env ruby
require 'fileutils'
require 'sequel'
require 'sequel/extensions/pretty_table'

class ScenarioDB

  attr_accessor :db, :db_file, :dbfile_path, :scenarios, :routes, :testdata

  def initialize(options={})
    if options[:db_file]
      self.db_file = options[:db_file]
    else
      self.db_file = File.dirname(File.expand_path(__FILE__)) + '/data/scenario_db.sqlite3'
    end

    handle_cli_options(options)
  end

  def handle_cli_options(options)
    if options[:setup]

      configure_database
      puts 'database setup complete.'
    end

    if !options[:add_scenario].nil? && options[:add_scenario].length == 1
      configure_database

      add_scenario(options[:add_scenario][0])
      if self.scenarios.count > 0
        Sequel::PrettyTable.print(self.scenarios)
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_scenario].nil?
      configure_database

      delete_scenario(options[:delete_scenario])
      if self.db[:scenarios].count > 0
        Sequel::PrettyTable.print(self.db[:scenarios])
      else
        puts 'No records to display.'
      end
    end

    if !options[:add_route].nil? && options[:add_route].length == 3
      configure_database

      add_route_for_scenario(options[:add_route][0], options[:add_route][1], options[:add_route][2])
      if self.routes.count > 0
        Sequel::PrettyTable.print(self.routes)
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_route].nil?
      configure_database

      delete_route(options[:delete_route])
      if self.db[:routes].count > 0
        Sequel::PrettyTable.print(self.routes)
      else
        puts 'No records to display.'
      end
    end

    if !options[:add_testdata].nil? && options[:add_testdata].length == 3
      configure_database

      add_testdata_for_scenario(options[:add_testdata][0], options[:add_testdata][1], options[:add_testdata][2])
      if self.testdata.count > 0
        Sequel::PrettyTable.print(self.testdata)
      else
        puts 'No records to display.'
      end
    end

    if !options[:delete_testdata].nil?
      configure_database

      delete_route(options[:delete_testdata])
      if self.testdata.count > 0
        Sequel::PrettyTable.print(self.testdata)
      else
        puts 'No records to display.'
      end
    end

    if options[:scenarios]
      configure_database

      if self.scenarios.count > 0
        Sequel::PrettyTable.print(self.scenarios)
      else
        puts 'No records to display.'
      end
    end

    if options[:routes]
      configure_database

      if self.routes.count > 0
        Sequel::PrettyTable.print(self.routes)
      else
        puts 'No records to display.'
      end
    end

    if options[:testdata]
      configure_database

      if self.testdata.count > 0
        Sequel::PrettyTable.print(self.testdata)
      else
        puts 'No records to display.'
      end
    end
  end

  def configure_database
    setup_database
    open_database
    create_scenarios_table
    create_routes_table
    create_testdata_table
  end

  def setup_database
    # Create an empty database file
    if !File.exists?(self.db_file)
      puts self.db_file
      File.open(self.db_file, 'w'){}
    end
  end

  def open_database
    # Open the database
    self.db ||= Sequel.sqlite(self.db_file)
    self.scenarios ||= self.db[:scenarios]
    self.routes ||= self.db[:routes]
    self.testdata ||= self.db[:testdata]
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
    scenarios = self.scenarios
    now = DateTime.now
    scenarios.insert(:name => name, :created_at => now, :updated_at => now)
  end

  def delete_scenario(scenario_id)
    self.scenarios.filter(:id => scenario_id).delete
  end

  def reset_scenarios
    self.scenarios.delete
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
    now = DateTime.now
    self.routes.insert( :scenario_id => scenario_id, :path => path, :fixture => fixture, :created_at => now, :updated_at => now)
#    puts "<scenario_id: #{scenario_id} #Path: #{path} fixture: #{fixture}>"
  end

  def delete_route(route_id)
    self.routes.filter(:id => route_id).delete
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
    now = DateTime.now
    self.testdata.insert(:name=>name, :value=>value,  :scenario_id => scenario_id, :created_at => now, :updated_at => now)
#    puts "<#Name: #{name} value: #{value} scenario_id: #{scenario_id}>"
  end

  def delete_testdata_for_scenario(testdata_id)
    self.testdata.filter(:id=>testdata_id).delete
  end

  # helper functions

  def get_ordered_scenarios
    return self.scenarios.order(:name).select(:id, :name).to_a
  end

  def delete_scenario_for_id(scenario_id)
    self.scenarios.filter(:id => scenario_id).delete
  end

  def get_scenario_for_id(scenario_id)
    return self.scenarios.where(:id => scenario_id).first
  end

  def get_last_scenario_id
    return self.scenarios.reverse_order(:id).first[:id]
  end

  def get_last_routes_id
    return self.routes.reverse_order(:id).first[:id]
  end

  def get_last_testdata_id
    return self.testdata.reverse_order(:id).first[:id]
  end



end




