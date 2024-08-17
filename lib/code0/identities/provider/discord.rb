# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Discord < BaseOauth
        attr_reader :config_loader

        def initialize(config_loader)
          @config_loader = config_loader
        end

        def token_url
          "https://discord.com/api/oauth2/token"
        end

        def token_payload(code)
          config = config_loader.call
          { code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret]
          }
        end

        def user_details_url
          "https://discord.com/api/users/@me"
        end

        def authorization_url
          config = config_loader.call
          "https://discord.com/oauth2/authorize?client_id=#{config[:client_id]}&response_type=code&redirect_uri=#{URI.encode_uri_component(config[:redirect_uri])}&scope=identify+openid+email"
        end


        def create_identity(response, *)
          body = response.parsed_response

          identifier = body["id"]
          username = body["username"]
          email = body["email"]

          Identity.new(:discord, identifier, username, email, nil, nil)
        end
      end
    end
  end
end
