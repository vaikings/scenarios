require './spec/spec_helper'
require './lib/scenarios/application/app'
require './lib/scenarios/scenario_db'

describe "scenario REST api" do

  def app
    ScenarioServer
  end

  attr_accessor :scenario_db

  before(:all) do
    options = {:db_file=>File.dirname(File.expand_path(__FILE__)) + '/../lib/scenarios/data/scenario_testdb.sqlite3'}
    self.scenario_db = ScenarioDB.new(options)
    self.scenario_db.configure_database()

  end

  before(:each) do
    self.scenario_db.reset_scenarios
    scenario_id = self.scenario_db.add_scenario("default")
    route_id = self.scenario_db.add_route_for_scenario('GET', '/hello', {"hello"=>"world"}.to_json, scenario_id)
  end

  #specs

  it 'GET /scenarios' do
    get '/scenarios'
    expect(last_response.status).to eq(200)
    file_data = parse_json(load_json('all_scenarios.json'))

    last_response.body.should be_json_eql(load_json('all_scenarios.json')).excluding("id")
  end

  it 'GET /scenarios/{scenario_id}' do
    last_scenario_id = self.scenario_db.get_last_scenario_id

    get '/scenarios/'+last_scenario_id.to_s

    expect(last_response.status).to eq(200)
    last_response.body.should be_json_eql(load_json("default_scenario.json")).excluding("id")
  end

  it "POST /scenarios/new" do
    post '/scenarios/new',"default",{}

    expect(last_response.status).to eq(200)
    last_response.body.should have_json_path("url")

  end

  it 'DELETE /scenarios/:scenario_id' do
    last_scenario_id = self.scenario_db.get_last_scenario_id

    delete '/scenarios/'+last_scenario_id.to_s
    expect(last_response.status).to eq(200)
  end

  it 'POST /scenarios/:scenario_id/routes/new' do
    last_scenario_id = self.scenario_db.get_last_scenario_id

    content = '{"path":"/v1/mystyle","fixture":"{\"json\":\"body\"}","route_type":"GET" }'
    path = '/scenarios/'+last_scenario_id.to_s + '/routes/new'
    post path, content, {}

    expect(last_response.status).to eq(200)
    last_response.body.should have_json_path('url')
  end

  it 'GET /scenarios/:scenario_id/routes' do
    last_scenario_id = self.scenario_db.get_last_scenario_id

    get '/scenarios/'+last_scenario_id.to_s+'/routes'

    expect(last_response.status).to eq(200)
    last_response.body.should have_json_path('routes')
  end

  it 'DELETE /scenarios/:scenario_id/routes/:route_id' do
    last_scenario_id = self.scenario_db.get_last_scenario_id
    last_route_id = self.scenario_db.get_last_routes_id

    delete '/scenarios/'+last_scenario_id.to_s+'/routes/'+last_route_id.to_s
    expect(last_response.status).to eq(200)

  end

  it 'GET /scenarios/:scenario_id/routes/:route_id' do
    last_scenario_id = self.scenario_db.get_last_scenario_id
    last_route_id = self.scenario_db.get_last_routes_id

    get '/scenarios/'+last_scenario_id.to_s+'/routes/'+last_route_id.to_s
    expect(last_response.status).to eq(200)
    puts(last_response.body)
  end

end 
