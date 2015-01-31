require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'sequel'
require 'json'
require_relative '../scenario_db'
require_relative './app_helpers.rb'

class ScenarioServer < Sinatra::Base
  DEFAULT_SCENARIO = 'default'
  attr_accessor :db, :scenario_db, :scenarios, :routes, :testdata
  register Sinatra::ConfigFile
  use Rack::MethodOverride

  configure :production do
    puts 'Production Environment'
    config_file File.expand_path('~/.scenarios') + '/config.yml'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_db.sqlite3'
    set :scenario, DEFAULT_SCENARIO
    enable :logging
    set :server, %w[thin mongrel webrick]
    if defined?(settings.localport)
      set :port, settings.localport
    else
      set :port, 4567
    end
  end   

  configure :development do
    puts 'Development Environment'
    config_file File.expand_path('~/.scenarios') + '/config.yml'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_db.sqlite3'
    set :scenario, DEFAULT_SCENARIO
    enable :logging
    set :server, %w[thin mongrel webrick]
    if defined?(settings.localport)
      set :port, settings.localport
    else
      set :port, 4567
    end

  end 
  
  configure :test do 
    puts 'Test Environment'
    config_file File.expand_path('~/.scenarios') + '/testconfig.yml'
    set :db_file , File.dirname(File.expand_path(__FILE__)) + '/../data/scenario_testdb.sqlite3'
    set :scenario, DEFAULT_SCENARIO
    enable :logging
    set :server, %w[thin mongrel webrick]
    set :port, 4567
  end

  before do
    if defined?(settings.localdbfile)
      puts "using db: "+settings.localdbfile
      options = {:db_file=>settings.localdbfile}
    else
      puts "using db: "+ settings.db_file
      options = {:db_file=>settings.db_file}
    end

    self.scenario_db = ScenarioDB.new(options)
    self.scenario_db.configure_database
    self.scenario_db.add_scenario('default')
  end

  after do
    self.scenario_db.close_database
  end

  get '/' do
    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      redirect('/scenarios')
    end
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
    routes = self.scenario_db.get_routes_for_scenario(params[:scenario_id])
    
    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))
      if params.has_key?('error')
        erb :'scenario', :locals => {'scenario'=>selected_scenario, 'routes'=>routes, 'error'=>params['error']}
      else
        erb :'scenario', :locals => {'scenario'=>selected_scenario, 'routes'=>routes, 'error'=>'' }
      end

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
    if (request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html'))

      valid_fixture = validate_json_string(params['fixture'])

      if valid_fixture
        self.scenario_db.add_route_for_scenario(params['route_type'],
                                                params['path'], 
                                                params['status_code'],
                                                params['headers'],
                                                params['fixture'], 
                                                params[:scenario_id])
        redirect('/scenarios/'+params[:scenario_id])
      else
        redirect('/scenarios/'+params[:scenario_id]+'?error=invalid%20json')
      end

    else
      json_body = JSON.parse(request.body.read)
      route_id = self.scenario_db.add_route_for_scenario(json_body['route_type'],
                                                         json_body['path'],
                                                         json_body['status_code'],
                                                         json_body['headers'], 
                                                         json_body['fixture'], 
                                                         params[:scenario_id])
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

  #default scenario

  get '/scenario' do
    [200, settings.scenario]
  end

  put '/scenario/:new_scenario' do
    name = params[:new_scenario]
    if valid_scenario(name)
      settings.scenario = name
      200
    else
      400
    end
  end

  delete '/scenario' do
    settings.scenario = DEFAULT_SCENARIO
    200
  end

  # route path calls
  get '/*' do
    #TODO: Validate scene from the list of scenarios
    ordered_scenarios = self.scenario_db.get_ordered_scenarios


    #TODO: dry up the implementation 
    #TODO: add ignore scene header 
    current_scenario = settings.scenario 
    if (request.env['HTTP_SCENE'])
      current_scenario = request.env['HTTP_SCENE']
    end

    route_type  = request.request_method.upcase
    path   = request.path.downcase

    status_code, header, fixture = get_fixture(route_type, path, current_scenario)
    if header.nil? || header == ""
      header = {'Content-Type' => 'application/json'}
    else
      header = eval(header)
    end 

    if fixture.nil?
      404
    else
      status status_code
      headers header
      body fixture
    end
  end

  post '/*' do
    content_type 'application/json'

    route_type  = request.request_method.upcase
    path    = request.path.downcase

    current_scenario = settings.scenario 
    if (request.env['HTTP_SCENE'])
      current_scenario = request.env['HTTP_SCENE']
    end

    status_code, header, fixture = get_fixture(route_type, path, current_scenario)
    if fixture.nil?
      404
    else
      [status_code, fixture]
    end
  end

  put '/*' do
    content_type 'application/json'

    route_type  = request.request_method.upcase
    path   = request.path.downcase

    current_scenario = settings.scenario 
    if (request.env['HTTP_SCENE'])
      current_scenario = request.env['HTTP_SCENE']
    end

    status_code, header, fixture = get_fixture(route_type, path, current_scenario)
    if fixture.nil?
      404
    else
      [status_code, fixture]
    end
    

  end

  delete '/*' do
    content_type 'application/json'

    route_type  = request.request_method.upcase
    path    = request.path.downcase

    current_scenario = settings.scenario 
    if (request.env['HTTP_SCENE'])
      current_scenario = request.env['HTTP_SCENE']
    end

    status_code, header, fixture = get_fixture(route_type, path, current_scenario)
    if fixture.nil?
      404
    else
      [status_code, fixture]
    end
  end

end

