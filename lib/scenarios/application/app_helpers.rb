require 'json'
require_relative '../scenario_db'

def validate_json_string (fixture)
  begin
    data = JSON.parse(fixture)
    return true
  rescue JSON::ParserError => e
    return false
  end
end

def valid_scenario (scenario_name)
  scenarios = self.scenario_db.get_scenario_names
  scenarios.include?(scenario_name)
end

def default?(name)
  name == "default"
end

def get_fixture(route_type, path, scenario_name)
  fixture = self.scenario_db.get_fixture_from_routes(route_type, path, scenario_name)

  if fixture.nil? and default?(scenario_name)
    fixture = self.scenario_db.get_fixture_from_routes(route_type, path, 'default')
  end

  fixture
end
