require 'todoable/request/base'
require 'todoable/request/errors'

module Todoable
  module Request
    module Items

      def new_item(list_id=nil, item_name=nil)
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
  end
end
