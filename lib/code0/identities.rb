# frozen_string_literal: true

require "httparty"

require_relative "identities/version"
require_relative "identities/identity"
require_relative "identities/provider/base_oauth"
require_relative "identities/provider/microsoft"
require_relative "identities/provider/discord"
require_relative "identities/provider/github"

module Code0
  module Identities
    class Error < StandardError; end
  end
end
