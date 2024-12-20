# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Gitlab < BaseOauth
        def base_url
          config[:base_url]
        end

        def token_url
          "#{base_url}/oauth/token"
        end

        def token_payload(code)
          { code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret] }
        end

        def user_details_url
          "#{base_url}/api/v4/user"
        end

        def authorization_url
          # rubocop:disable Layout/LineLength
          base_url + "/oauth/authorize?client_id=#{config[:client_id]}&response_type=code&redirect_uri=#{URI.encode_uri_component(config[:redirect_uri])}&scope=read_user"
          # rubocop:enable Layout/LineLength
        end

        def create_identity(response, *)
          body = response.parsed_response

          identifier = body["id"]
          username = body["username"]
          email = body["email"]

          Identity.new(config[:provider_name], identifier, username, email, nil, nil)
        end
      end
    end
  end
end
