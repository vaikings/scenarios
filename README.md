# Scenarios

This gem is used to setup a quick local server using sinatra

As the server is started for the first time, point your browser to http://localhost:4567/scenarios  
Here a "default" scenario is present. You can add various routes to this scenario.

for e.g. a sample route added would be
GET , '/v1/mystyle' {"season":"summer"}

Now when you open browser and make a get request to 'http://localhost:4567/v1/mystyle' you will receive the json fixture passed in the route.  

This server also lets you add different scenario and lets you add a different response {"season":"winter"} for the same api endpoint under different scenario. e.g. cold_weather

When you make a get request and then specify header SCENE with value as your scenario, the response under that scenario would be returned.

If you make a get request that is not defined for a particular scenario but is defined in the default scenario, then the response from the default scenario would be returned.


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
