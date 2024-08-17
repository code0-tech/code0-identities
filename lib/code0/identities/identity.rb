# frozen_string_literal: true

module Code0
  module Identities
    Identity = Struct.new(:provider, :identifier, :username, :email, :firstname, :lastname)
  end
end
