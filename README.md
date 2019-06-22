# TDODABLE

A gem that wraps a Todo API

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

## Possible extensions

- a utility function that autorenews your auth token given a username and password (if you prefer // feel comfortable giving out this information)
- a JSON? flag that returns either pure JSON or the objects
- a "custom" endpoint that allows you to pass an API path and handles auth for you


## Refactor

- refactor out an AuthToken class, perhaps OStruct it


Notes:

- elected to return lists of Ruby objects (as opposed to JSON) as assumed the consumer would be Ruby backends (not backend intermediaries passing to a frontend or sth strange like that);
- therefore handle API errors at the library level instead of passing them on
- opt to allow the user to configure the client as desired (pass in username, pass), though also able to read from env for convenience and security ie if running in webserver

- chose to return Ruby objects since assume this is a server-side gem meant to be used in Ruby (use a JS library if on client side and want JSON API shortcuts)
- chose to not error-check inputs because assume API will do that and creates extra maintainability workload for us to wrap all errors - instead just pass them through as API owner updates them) -- purpose of this gem is basically to provide convenience methods + access/auth to the API, for ease of use / developer happiness
