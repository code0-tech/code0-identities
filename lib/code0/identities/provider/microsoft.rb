# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Microsoft < BaseOauth
        def base_url
          "https://graph.microsoft.com/"
        end

        def token_url
          "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"
        end

        def token_payload(code)
          { code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret] }
        end

        def user_details_url
          "https://graph.microsoft.com/oidc/userinfo"
        end

        def authorization_url
          "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize?client_id=#{config[:client_id]}&response_type=code&redirect_uri=#{config[:redirect_uri]}&response_mode=query&scope=email%20profile%20openid"
        end

        def create_identity(response, *)
          body = response.parsed_response

          identifier = body["sub"]
          firstname = body["givenname"]
          lastname = body["familyname"]
          email = body["email"]

          Identity.new(config[:provider_name], identifier, nil, email, firstname, lastname)
        end
      end
    end
  end
end
