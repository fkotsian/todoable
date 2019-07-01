# TODOABLE

A gem that wraps the Todoable API

## Features

- GET /lists
- POST /lists
- GET /lists/:id
- PATCH /lists/:id
- DELETE /lists/:id
- POST /lists/:id/items
- PUT /lists/:id/items/:item_id/finish
- DELETE /lists/:id/items/:item_id

## Desired components

- tests for each method that ensures is working as intended
- built-in authentication handling
- Ruby-native return values for ease of use
- input and error handling for developer friendliness

## Notes:

- pretty fun to write!
- chose to return Ruby objects since assume this is a server-side gem meant to be used in Ruby (use a JS library if on client side and want JSON API shortcuts)
- chose to pass any API error on to user to make gem more maintainable - if Todoable API changes, our gem should remain usable

## Possible extensions:

- API_VERSION switch if multiple API versions exist
- JSON flag to return JSON instead of Ruby objects if desired (for example, if passing to a JS client for some reason)
- split API handlers, auth handlers, and errors into own files if desired

## Usage:

- run tests with `rake`
- manual instantiation: `Todoable::Api.new(username, password)`

