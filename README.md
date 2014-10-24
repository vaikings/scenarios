# Scenarios

This gem is used to setup a quick local api server

As the server is started for the first time, point your browser to http://localhost:4567/scenarios . 
Here a "default" scenario is present. You can add various routes to this scenario. 

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

The server can be started in daemon mode by 

scenario_service  start

or 

without a daemon mode

scenario_service start -T 

## Configuration 

a yaml file can be provided at the following location 
~/.scenarios/config.yml 
to hold the port to be used and the path of a sqlite database. 
If this file is not provided, the db file is created inside the 
gem folder. 

Please see sample_config.yml for more info.

