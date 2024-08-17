module Code0
  module Identities
    module Provider
      class BaseOauth

        def authorization_url
          raise NotImplementedError
        end

        def token_url
          raise NotImplementedError
        end

        def user_details_url
          raise NotImplementedError
        end

        def token_payload(code)
          raise NotImplementedError
        end


        def load_identity(code)
          token, token_type = access_token code

          response = p HTTParty.get(user_details_url,
                                  headers: {
                                    Authorization: "#{token_type} #{token}",
                                    "Accept" => "application/json"
                                  })

          check_response response

          create_identity response, token, token_type
        end

        private

        def access_token(code)
          response = HTTParty.post(token_url,
                                   body: URI.encode_www_form(token_payload(code)), headers: {
              "Content-Type" => "application/x-www-form-urlencoded",
              "Accept" => "application/json"
            })

          check_response response

          parsed = response.parsed_response

          [parsed["access_token"], parsed["token_type"]]
        end

        def check_response(response)
          return if response.code == 200

          raise Error, response.body
        end

        def create_identity(*)
          raise NotImplementedError
        end
      end
    end
  end
end