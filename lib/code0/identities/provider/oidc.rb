# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Oidc < BaseOauth
        def validate_config!
          required_keys = %i[client_id client_secret redirect_uri token_url user_details_url authorization_url]

          missing_keys = required_keys - config.keys
          invalid_keys = config.keys - required_keys - [:provider_name]

          raise MissingConfigurationError, "Missing: #{missing_keys.inspect}" if missing_keys.any?
          raise InvalidConfigurationError, "Invalid: #{invalid_keys.inspect}" if invalid_keys.any?
        end

        def token_url
          config[:token_url]
        end

        def token_payload(code)
          { code: code,
            grant_type: "authorization_code",
            redirect_uri: config[:redirect_uri],
            client_id: config[:client_id],
            client_secret: config[:client_secret] }
        end

        def user_details_url
          config[:user_details_url]
        end

        def authorization_url
          config[:authorization_url]
            .gsub("{client_id}", config[:client_id])
            .gsub("{redirect_uri}", config[:redirect_uri])
        end

        def create_identity(response, *)
          body = response.parsed_response

          Identity.new(config[:provider_name],
                       find_attribute(body, config[:attribute_statements][:identifier]),
                       find_attribute(body, config[:attribute_statements][:username]),
                       find_attribute(body, config[:attribute_statements][:email]),
                       find_attribute(body, config[:attribute_statements][:firstname]),
                       find_attribute(body, config[:attribute_statements][:lastname]))
        end

        def config
          config = super

          # rubocop:disable Layout/LineLength
          config[:provider_name] ||= :oidc
          config[:attribute_statements] ||= {}
          config[:attribute_statements][:identifier] ||= %w[sub id identifier]
          config[:attribute_statements][:username] ||= %w[username name login]
          config[:attribute_statements][:email] ||= %w[email mail]
          config[:attribute_statements][:firstname] ||= %w[first_name firstname firstName givenname given_name givenName]
          config[:attribute_statements][:lastname] ||= %w[last_name lastname lastName family_name familyName familyname]
          # rubocop:enable Layout/LineLength

          config
        end

        def find_attribute(attributes, attribute_statements)
          attribute_statements.each do |statement|
            return attributes[statement] unless attributes[statement].nil?
          end
          nil
        end
      end
    end
  end
end
