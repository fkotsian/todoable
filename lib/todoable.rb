require 'http'
require 'ostruct'

module Todoable
  class Api
    API_ROOT = "http://todoable.teachable.tech/api"

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

    def request_base(login=false)
      if login
        HTTP
          .headers(
            accept: 'application/json',
            content_type: 'application/json',
          )
          .basic_auth(
            user: @user,
            pass: @pass,
          )
      else
        HTTP
          .headers(
            accept: 'application/json',
            content_type: 'application/json',
          )
          .auth("Token token=\"#{token}\"")
      end
    end

    def new_token
      if (!@user || !@pass)
        raise Todoable::ApiError.new "Please set Todoable API username and password in ENV or constructor in order to make requests"
      end

      res = request_base(login=true)
        .post(
          "#{API_ROOT}/authenticate",
        )

      json = JSON.parse(res)
      @token = json['token']
      @expiry = json['expires_at']

      [@token, @expiry]
    end

    def token
      # generate new token if DNE or expired
      if (
          !@token ||
          @expiry && Time.now.to_i >= Time.parse(@expiry).to_i
      )
        new_token
      end

      @token
    end

    def token_expiration
      @expiry
    end

    def lists
      res = request_base
        .get("#{API_ROOT}/lists")

      json = JSON.parse(res, object_class: OpenStruct)
      lists = json.lists
      lists
    end

    def new_list(list_name=nil)
      if !list_name
        raise Todoable::ArgError.new "Please provide a list name"
      end

      res = request_base
        .post(
          "#{API_ROOT}/lists",
          json: {
            list: {
              name: list_name,
            }
          }
        )

      json = JSON.parse(res, object_class: OpenStruct)

      if res.status == 422
        error_msgs = json.each_pair
          .map {|pair| pair.join(" ") }
          .join(", ")
        raise Todoable::ApiError.new error_msgs
      end

      json
    end

    def list(list_id=nil)
      if !list_id
        raise Todoable::ArgError.new "Please provide a list ID"
      end

      res = request_base
        .get("#{API_ROOT}/lists/#{list_id}")

      if res.status == 204 || res.status == 404
        return nil
      end

      json = JSON.parse(res, object_class: OpenStruct)
      json
    end

    def update_list(list_id=nil, new_name)
      if !list_id
        raise Todoable::ArgError.new "Please provide a list ID"
      end
      if !new_name
        raise Todoable::ArgError.new "Please provide your new list name"
      end

      res = request_base
        .patch(
          "#{API_ROOT}/lists/#{list_id}",
          json: {
            list: {
              name: new_name,
            }
          }
        )

      if res.status != 200
        raise Todoable::ApiError.new "Could not update list #{list_id}: list not found"
      else
        return true
      end
    end

    def delete_list(list_id=nil)
      res = request_base
        .delete("#{API_ROOT}/lists/#{list_id}")

      if res.status == 204
        true
      else
        raise Todoable::ApiError.new "Unable to delete list #{list_id}"
      end
    end

    def new_item(list_id, item_name)
      if !list_id
        raise Todoable::ArgError.new "Please provide a list ID"
      end
      if !item_name || item_name.length == 0
        raise Todoable::ArgError.new "Please provide an item title"
      end

      res = request_base
        .post(
          "#{API_ROOT}/lists/#{list_id}/items",
          json: {
            item: {
              name: item_name,
            }
          }
        )

      if res.status == 201
        return true
      elsif res.status == 422
        raise Todoable::ApiError.new "Unable to add item to list #{list_id}"
      elsif res.status == 404
        raise Todoable::ApiError.new "List #{list_id} not found"
      else
        raise Todoable::ApiError.new "An unknown error occurred"
      end
    end

    def finish_item(list_id, item_id)
      if !list_id
        raise Todoable::ArgError.new "Please provide a list ID"
      end
      if !item_id
        raise Todoable::ArgError.new "Please provide an item ID"
      end

      res = request_base
        .put(
          "#{API_ROOT}/lists/#{list_id}/items/#{item_id}/finish",
        )

      if res.status == 200
        return true
      elsif res.status == 404
        raise Todoable::ApiError.new "List #{list_id} or item #{item_id} not found"
      else
        raise Todoable::ApiError.new "An unknown error occurred"
      end
    end

    def delete_item(list_id, item_id)
      if !list_id
        raise Todoable::ArgError.new "Please provide a list ID"
      end
      if !item_id
        raise Todoable::ArgError.new "Please provide an item ID"
      end

      res = request_base
        .delete(
          "#{API_ROOT}/lists/#{list_id}/items/#{item_id}",
        )

      if res.status == 204
        return true
      elsif res.status == 404
        raise Todoable::ApiError.new "List #{list_id} or item #{item_id} not found"
      else
        raise Todoable::ApiError.new "An unknown error occurred"
      end
    end

  end

  class ApiError < StandardError
    def initialize(msg)
      super("API Error Observed: #{msg}")
    end
  end

  class ArgError < StandardError
  end
end
