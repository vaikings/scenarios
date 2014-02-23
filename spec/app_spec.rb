require './spec/spec_helper'
require './lib/scenarios/application/app'
require './lib/scenarios/scenario_db'

describe "scenario REST api" do

  def app
    ScenarioServer
  end

  attr_accessor :scenario_db

  before do
    options = {"db_file"=>File.dirname(File.expand_path(__FILE__)) + './lib/scenarios/data/scenario_testdb.sqlite3'}
    self.scenario_db = ScenarioDB.new(options)
    self.scenario_db.configure_database()

  end

  before(:each) do
    self.scenario_db.reset_scenarios
    self.scenario_db.add_scenario("default")
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

    content = '{"path":"/v1/mystyle","fixture":"{\"json\":\"body\"}","request":"GET" }'
    path = '/scenarios/'+last_scenario_id.to_s + '/routes/new'
    post path, content, {}

    expect(last_response.status).to eq(200)
    #last_response.body.should have_json_path('url')
  end

end 
