require './spec/spec_helper'
require './app'

describe "scenario REST api" do

  def app
    ScenarioServer
  end

  before(:all) do
    configure_test_db()
  end

  before(:each) do
    reset_test_db()
  end
  #specs

  it 'GET /scenarios' do
    get '/scenarios'
    expect(last_response.status).to eq(200)
    file_data = parse_json(load_json('all_scenarios.json'))

    last_response.body.should be_json_eql(load_json('all_scenarios.json')).excluding("id")
  end

  it 'GET /scenarios/{scenario_id}' do
    post '/scenarios/new',"default",{}

    resp = parse_json(last_response.body)
    url= resp["url"]

    get url

    expect(last_response.status).to eq(200)
    last_response.body.should be_json_eql(load_json("default_scenario.json")).excluding("id")
  end

  it "POST /scenarios/new" do
    post '/scenarios/new',"default",{}

    expect(last_response.status).to eq(200)
    last_response.body.should have_json_path("url")
  end

  it 'DELETE /scenarios/:scenario_id' do
    post '/scenarios/new',"default",{}

    resp = parse_json(last_response.body)
    url= resp["url"]

    delete url
    expect(last_response.status).to eq(200)
  end

end 
