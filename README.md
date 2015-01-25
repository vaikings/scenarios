# Scenarios

This gem can be used to setup a quick local api server.

## Installation

Add this line to your application's Gemfile:

    gem 'scenario_server'

Or manually install it:

    $ gem install scenario_server

## Configuration

A yaml file when provided at the following location
> ~/.scenarios/config.yml

can be used to define the port and path of the sqlite database holding the routes.
If this file is not provided, the db file is created wherever the ruby gem is installed.

#### Config.yml
>localport: 4567
>localdbfile: /Users/vaibhav/.scenarios/scenarios.sqlite3

## Usage

The server can be started in daemon mode by

    scenario_service  start

or without a daemon mode

    scenario_service start -t

### What are Scenarios
Scenarios is a context in which you are using your local api server. Each scenario contains one or more routes.

e.g.

#####Default
* GET , '/v1/season', 200, {"name":"summer","temperature":70}
* GET , '/v1/city' , 200, {"name":"Seattle"}

#####Rainy
  * GET , '/v1/season', 200, {"name":"rainy","temperature":50,"precipitation":5}

#####Error
  * GET , '/v1/season', 404, {"error":"sensors not found"}
  * GET , '/v1/city' , 500, {"error":"server error"}

Scenarios are usually broken up as:
* For handling most common api response: 'Default' Scenario server comes with the server and this cannot be deleted.
* For handling alternate api response e.g. 'Rainy' with precipitation information in our current example
* For handling error responses e.g. 'error'

On startup, all responses returned from the server are from default scenario.

### To fetch data from routes

Make a request with scenario server url and path of the route with the correct request type. Also specify header **SCENE** with your scenario name,
This will return the fixture under that scenario, with status code and headers specified
e.g.

    curl -X GET -H "SCENE:rainy" http://localhost:4567/v1/season

If the header **SCENE** is not present, the current scenario set on the server would be used.

will return
` {"name":"rainy","temperature":50,"precipitation":5} `

### To list all scenarios
    curl http://localhost:4567/scenarios
  or point the browser to http://localhost:4567/scenarios

### To check the current scenario
    curl http://localhost:4567/scenario
  or point the browser to http://localhost:4567/scenario

### To change the current scenario from 'default' to 'rainy'
    curl -X PUT  http://localhost:4567/scenario/rainy -d ''

Note: If you are not in 'default' scenario and make a call to a route which is not defined, server will also check 'default' for that route. If present, it will return data from that route else will give a 404.

### To add a new scenario 'winter'
    curl -X POST  http://localhost:4567/scenarios/new -d 'winter'
or point the browser to http://localhost:4567/scenarios and add name in the text box below **New scenario** and then click **submit**.

### To delete scenario 'winter'
Given that winter scenario has an id **3**

      curl -X DELETE  http://localhost:4567/scenarios/3

### To get all routes from 'rainy' scenario
Given that 'rainy' scenario has an id **2**

      curl http://localhost:4567/scenarios/2/routes
