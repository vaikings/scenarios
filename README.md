# Scenarios

This gem is used to setup a mock sinatra server, to be used when developing apps or for ui automation using frank. 

As the server is started for the first time, point your browser to http://localhost:4567/scenarios . Here a "default" 
scenario is present. You can add various routes to this scenario. 

for e.g. a sample route added would be 
GET , '/v1/mystyle' {"Hello":"world"} 

Now when you open browser and make a REST get call to '/v1/mystyle' you will receive the json fixture passed in the route.  

## Installation

Add this line to your application's Gemfile:

    gem 'scenario_server'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scenario_server

## Usage

This would provide with the following binaries
- scenarios 
- scenariosdb 
