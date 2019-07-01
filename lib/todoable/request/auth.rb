require 'http'
require 'ostruct'
require 'todoable/request/base'
require 'todoable/request/errors'

module Todoable
  module Request
    module Auth

      def login
        HTTP
          .headers(
            accept: 'application/json',
            content_type: 'application/json',
          )
          .basic_auth(
            user: @user,
            pass: @pass,
          )
      end

      def new_token
        if (!@user || !@pass)
          raise Todoable::ApiError.new "Please set Todoable API username and password in ENV or constructor in order to make requests"
        end

        res = login
          .post(
            "#{API_ROOT}/authenticate",
          )

        json = api_object(res)
        @token = json.token
        @expiry = json.expires_at

        [@token, @expiry]
      end

      def token
        # generate new token if DNE or expired
        if (
          !@token ||
          token_expired?
        )
          new_token
        end

        @token
      end

      def token_expiration
        @expiry
      end

      def token_expired?
        (@expiry && Time.now.to_i >= Time.parse(@expiry).to_i)
      end

    end
  end
end
