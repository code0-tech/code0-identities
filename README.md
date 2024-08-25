# Code0::Identities [![Build Status](https://img.shields.io/github/actions/workflow/status/code0-tech/code0-identities/main.yml?branch=main)](https://github.com/code0-tech/code0-identities/actions) ![GitHub Release](https://img.shields.io/github/v/release/code0-tech/code0-identities) ![Discord](https://img.shields.io/discord/1173625923724124200?label=Discord&color=blue)

This gem can load and validate external identities

## Supported platforms

OAuth:
- Google
- Discord
- Microsoft
- Github
- Gitlab

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add code0-identities

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install code0-identities

## Usage

You can use predefined Providers to load an identity from for example Discord:
```ruby

require "code0/identities"

begin

  identity = Code0::Identities::Provider::Discord.new(
    {
      redirect_uri : "http://localhost:8080/redirect",
        client_id : "id"
      client_secret : "xxxx"
    }).load_identity({ code: "a_valid_code" })

rescue Code0::Error => e
  puts "Error occurred while loading the identity", e
  exit!
end

# Then you can use the details from the user
puts identity.provider # = :discord
puts identity.username
puts identity.identifier
# ...

```

Or you can use a provider with multiple configured providers:

```ruby

require "code0/identities"

identity_provider = Code0::Identities::IdentityProvider.new

identity_provider.add_provider(:gitlab, my_gitlab_configuration)
identity_provider.add_named_provider(:my_custom_gitlab_provider, :gitlab, my_custom_gitlab_provider_configuration)

# Now you can either use the custom "my_custom_gitlab_provider" provider
# or the "gitlab" provider

identity_provider.load_identity(:gitlab, params)

# or

identity_provider.load_identity(:my_custom_gitlab_provider, params)

```

We also support passing in a function as a configuration instead of a hash

```ruby

def get_identity
  provider = Code0::Identities::Provider::Discord.new(-> { fetch_configuration })

  provider.load_identity(params)
end

def fetch_configuration
  # Do some database action, to dynamicly load the configuration
  {
    redirect_uri: "http://localhost:8080/redirect",
    client_id: "some dynamic value",
    client_secret: "xxxx"
  }
end

```