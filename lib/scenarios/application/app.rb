require 'sinatra'
require 'sinatra/respond_with'
require 'sequel'
require 'json'
require_relative '../scenario_db'

class ScenarioServer < Sinatra::Base

  attr_accessor :db, :scenario_db, :scenarios, :routes, :testdata
  use Rack::MethodOverride

  configure :production do
    puts 'Production Environment'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_db.sqlite3'
    enable :logging
  end   

  configure :development do
    puts 'Development Environment'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_db.sqlite3'
    enable :logging
  end 
  
  configure :test do 
    puts 'Test Environment'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_testdb.sqlite3'
    enable :logging
  end

  before do
    options = {:db_file=>settings.db_file}
    self.scenario_db = ScenarioDB.new(options)
    self.scenario_db.configure_database()
  end

  get '/scenarios' do

    ordered_scenarios = self.scenario_db.get_ordered_scenarios

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      erb :'index', :locals => { :scenarios => ordered_scenarios }
    else
      content_type 'application/json', :charset => 'utf-8'
      content = {'scenarios'=>ordered_scenarios}.to_json
      [200,content]
    end
  end

  get '/scenarios/:scenario_id' do
    selected_scenario = self.scenario_db.get_scenario_for_id(params[:scenario_id])

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
      self.scenario_db.add_scenario(params[:new_scenario])
      redirect('/scenarios')
    else
      name = request.body.read
      scenario_id = self.scenario_db.add_scenario(name)

      [200,{"url"=>"/scenarios/"+scenario_id.to_s}.to_json]
    end
  end

  delete '/scenarios/:scenario_id' do
    self.scenario_db.delete_scenario_for_id(params[:scenario_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      redirect('/scenarios')
    else
      [200]
    end
  end

  post '/scenarios/:scenario_id/routes/new' do
    json_body = JSON.parse(request.body.read)

    route_id = self.scenario_db.add_route_for_scenario(json_body['route_type'],
                                                       json_body['path'], json_body['fixture'], params[:scenario_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      redirect('/scenarios/'+params[:scenario_id])
    else
      content = {'url'=>'/scenarios/'+params[:scenario_id]+'/routes/'+route_id.to_s}.to_json
      [200, content]
    end
  end

  get '/scenarios/:scenario_id/routes' do
    routes = self.scenario_db.get_routes_for_scenario(params[:scenario_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      erb :'scenario', :locals => { :routes => routes }
    else
      content_type 'application/json', :charset => 'utf-8'
      content = {'routes'=>routes}.to_json

      [200,content]
    end
  end

  delete '/scenarios/:scenario_id/routes/:route_id' do
    self.scenario_db.delete_route(params[:route_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      redirect('/scenarios/'+ params[:scenario_id] )
    else
      [200]
    end
  end

  get '/scenarios/:scenario_id/routes/:route_id' do
    route = self.scenario_db.get_route(params[:route_id])

    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      erb :'route', :locals => { :route => route }
    else
      content_type 'application/json', :charset => 'utf-8'
      content = route.to_json

      [200,content]
    end
  end

end

