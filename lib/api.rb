require 'request/base'
require 'request/auth'
require 'request/lists'
require 'request/items'
require 'request/errors'

module Todoable
  class Api

    include Todoable::Request
    include Todoable::Request::Auth
    include Todoable::Request::Lists
    include Todoable::Request::Items

    def initialize(
      token: nil,
      expiry: nil,
      user: ENV['TODOABLE_USER'],
      pass: ENV['TODOABLE_PASS']
    )
      @token = token
      @expiry = expiry
      @user = user
      @pass = pass
    end
  end
end
