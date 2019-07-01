require 'todoable/request/base'
require 'todoable/request/errors'

module Todoable
  module Request
    module Lists

      def lists
        res = request_base
          .get("#{API_ROOT}/lists")

        json = api_object(res)
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

        json = api_object(res)

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

        json = api_object(res)
        json
      end

      def update_list(list_id=nil, new_name=nil)
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

    end
  end
end
