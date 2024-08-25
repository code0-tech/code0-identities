# frozen_string_literal: true

module Code0
  module Identities
    class IdentityProvider
      attr_reader :providers

      def initialize
        @providers = {}
      end

      def add_provider(provider_type, config)
        add_named_provider provider_type, provider_type, config
      end

      def add_named_provider(provider_id, provider_type, config)
        provider = Identities::Provider.const_get(provider_type.capitalize).new(config)
        providers[provider_id] = provider
      end

      def load_identity(provider_id, params)
        provider = providers[provider_id]
        if provider.nil?
          raise Error, "Provider with id '#{provider_id}' is not configured, did you forget to use add_provider"
        end

        provider.load_identity(params)
      end
    end
  end
end
