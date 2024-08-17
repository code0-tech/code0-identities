# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Github < BaseOauth
        attr_reader :config_loader

        def initialize(config_loader)
          @config_loader = config_loader
        end

        def token_url
          "https://github.com/login/oauth/access_token"
        end

        def token_payload(code)
          config = config_loader.call
          { code: code,
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret]
          }
        end

        def user_details_url
          "https://api.github.com/user"
        end

        def authorization_url
          config = config_loader.call
          "https://github.com/login/oauth/authorize?client_id=#{config[:client_id]}&redirect_uri=#{URI.encode_uri_component(config[:redirect_uri])}&scope=read:user+user:email"
        end

        def private_email(access_token, token_type)
          response = HTTParty.get(user_details_url + "/emails",
                                  headers: {
                                    Authorization: "#{token_type} #{access_token}",
                                    "Accept" => "application/json"
                                  })
          body = response.parsed_response

          body.find { |email_object| email_object["primary"] }["email"]
        end

        def create_identity(response, access_token, token_type)
          body = response.parsed_response

          identifier = body["id"]
          username = body["login"]
          email = body["email"]

          email = private_email(access_token, token_type) if email.nil?



          Identity.new(:github, identifier, username, email, nil, nil)
        end
      end
    end
  end
end
