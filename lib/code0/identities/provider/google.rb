# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Google < BaseOauth
        def base_url
          "https://accounts.google.com"
        end

        def token_url
          "https://oauth2.googleapis.com/token"
        end

        def token_payload(code)
          {
            code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret]
          }
        end

        def user_details_url
          "https://www.googleapis.com/oauth2/v3/userinfo"
        end

        def authorization_url
          # rubocop:disable Layout/LineLength
          base_url + "/o/oauth2/v2/auth?client_id=#{config[:client_id]}&response_type=code&redirect_uri=#{URI.encode_www_form_component(config[:redirect_uri])}&scope=openid%20email%20profile"
          # rubocop:enable Layout/LineLength
        end

        def create_identity(response, *)
          body = response.parsed_response

          identifier = body["sub"]
          username = body["name"]
          email = body["email"]
          firstname = body["given_name"]
          lastname = body["family_name"]

          Identity.new(config[:provider_name], identifier, username, email, firstname, lastname)
        end
      end
    end
  end
end
