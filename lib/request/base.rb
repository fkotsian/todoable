module Todoable
  module Request

    API_ROOT = "http://todoable.teachable.tech/api"

    def request_base
      HTTP
        .headers(
          accept: 'application/json',
          content_type: 'application/json',
        )
        .auth("Token token=\"#{token}\"")
    end


    private

    def api_object(response)
      JSON.parse(response, object_class: OpenStruct)
    end

  end
end
