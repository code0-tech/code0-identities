# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Discord < BaseOauth
        def validate_config!
          required_keys = %i[redirect_uri client_id client_secret]

          missing_keys = required_keys - config.keys
          invalid_keys = config.keys - required_keys - [:provider_name]

          raise MissingConfigurationError, "Missing: #{missing_keys.inspect}" if missing_keys.any?
          raise InvalidConfigurationError, "Invalid: #{invalid_keys.inspect}" if invalid_keys.any?
        end

        def token_url
          "https://discord.com/api/oauth2/token"
        end

        def token_payload(code)
          { code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret] }
        end

        def user_details_url
          "https://discord.com/api/users/@me"
        end

        def authorization_url
          "https://discord.com/oauth2/authorize?client_id=#{config[:client_id]}&response_type=code&redirect_uri=#{URI.encode_uri_component(config[:redirect_uri])}&scope=identify+openid+email"
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
