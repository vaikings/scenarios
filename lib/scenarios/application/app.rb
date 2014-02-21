require 'sinatra'
require 'sinatra/respond_with'
require 'sequel'
require 'json'
require_relative '../scenario_db_setup'

class ScenarioServer < Sinatra::Base

  attr_accessor :db, :scenarios, :routes, :testdata
  use Rack::MethodOverride

  configure :production do
    puts 'Production Environment'
    enable :logging
  end   

  configure :development do
    puts 'Development Environment'
    set :db_filename, 'scenario_db.sqlite3'
    enable :logging
  end 
  
  configure :test do 
    puts 'Test Environment'
    set :db_filename, 'scenario_testdb.sqlite3'
    enable :logging
  end


 def configure_db(db_filename)
   db_file = File.dirname(File.expand_path(__FILE__)) + '/../data/'+db_filename  
   if !File.exists?(db_file)
     scenario_db_setup = ScenarioDbSetup.new
     scenario_db_setup.configure_database(db_filename)
   end
 end

 
  before do
   configure_db(settings.db_filename)  
    
    file_path = File.dirname(File.expand_path(__FILE__)) + '/../data/'+settings.db_filename 
    self.db ||= Sequel.sqlite(file_path)
    self.scenarios ||= self.db[:scenarios]
    self.routes ||= self.db[:routes]
    self.testdata ||= self.db[:testdata]
  end

  get '/scenarios' do
    ordered_scenarios = self.scenarios.order(:name).select(:id, :name).to_a

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      erb :'index', :locals => { :scenarios => ordered_scenarios }
    else
      content_type 'application/json', :charset => 'utf-8'
      content = {'scenarios'=>ordered_scenarios}.to_json
      [200,content]
    end
  end

  get '/scenarios/:scenario_id' do
    selected_scenario = get_scenario_for_id(params[:scenario_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      erb :'scenario', :locals => {'scenario'=>selected_scenario}
    else
      content_type 'application/json', :charset => 'utf-8'
      content = selected_scenario.to_json
      [200,content]
    end
  end

  post '/scenarios/new' do
    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      add_new_scenario(params[:new_scenario])
      redirect('/scenarios')
    else
      name = request.body.read
      scenario_id = add_new_scenario(name)

      [200,{"url"=>"/scenarios/"+scenario_id.to_s}.to_json]
    end
  end

  delete '/scenarios/:scenario_id' do
    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      delete_scenario_for_id(params[:scenario_id])
      redirect('/scenarios')
    else
      delete_scenario_for_id(params[:scenario_id])
      [200]
    end
  end

#private methods
  private
  
  def add_new_scenario(name)
    p = { :name => name }
    now = DateTime.now
    p[:created_at] = now
    p[:updated_at] = now

    new_scenario_id = self.scenarios.insert(p)
    return new_scenario_id
  end

  def delete_scenario_for_id(scenario_id)
    scenarios.filter(:id => scenario_id).delete
  end

  def get_scenario_for_id(scenario_id)
    scenario = self.scenarios.where(:id => scenario_id).first
    return scenario
  end

end

