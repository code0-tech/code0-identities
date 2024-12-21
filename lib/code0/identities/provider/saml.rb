# frozen_string_literal: true

module Code0
  module Identities
    module Provider
      class Saml
        attr_reader :config_loader

        def initialize(config_loader)
          @config_loader = config_loader
        end

        def authorization_url
          request = OneLogin::RubySaml::Authrequest.new
          request.create(create_settings)

          request.instance_variable_get :@login_url
        end

        def load_identity(**params)
          response = OneLogin::RubySaml::Response.new(params[:SAMLResponse],
                                                      { **config[:response_settings], settings: create_settings })
          attributes = response.attributes

          Identity.new(config[:provider_name],
                       response.name_id,
                       find_attribute(attributes, config[:attribute_statements][:username]),
                       find_attribute(attributes, config[:attribute_statements][:email]),
                       find_attribute(attributes, config[:attribute_statements][:firstname]),
                       find_attribute(attributes, config[:attribute_statements][:lastname]))
        end

        private

        def find_attribute(attributes, attribute_statements)
          attribute_statements.each do |statement|
            return attributes[statement] unless attributes[statement].nil?
          end
          nil
        end

        def create_settings
          if config[:metadata_url].nil?
            settings = OneLogin::RubySaml::Settings.new
          else
            idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
            settings = idp_metadata_parser.parse_remote(config[:metadata_url])
          end

          settings.name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"

          config[:settings].each do |key, value|
            settings.send(:"#{key}=", value)
          end
          settings
        end

        def config
          config = config_loader
          config = config_loader.call if config_loader.is_a?(Proc)

          # rubocop:disable Layout/LineLength
          config[:provider_name] ||= :saml
          config[:response_settings] ||= {}
          config[:settings] ||= {}
          config[:attribute_statements] ||= {}
          config[:attribute_statements][:username] ||= %w[username name http://schemas.goauthentik.io/2021/02/saml/username]
          config[:attribute_statements][:email] ||= %w[email mail http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress http://schemas.microsoft.com/ws/2008/06/identity/claims/emailaddress]
          config[:attribute_statements][:firstname] ||= %w[first_name firstname firstName http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname http://schemas.microsoft.com/ws/2008/06/identity/claims/givenname]
          config[:attribute_statements][:lastname] ||= %w[last_name lastname lastName http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname http://schemas.microsoft.com/ws/2008/06/identity/claims/surname]
          # rubocop:enable Layout/LineLength

          config
        end
      end
    end
  end
end
