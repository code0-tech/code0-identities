# Code0::Identities [![Build Status](https://img.shields.io/github/actions/workflow/status/code0-tech/code0-identities/main.yml?branch=main)](https://github.com/code0-tech/code0-identities/actions) ![GitHub Release](https://img.shields.io/github/v/release/code0-tech/code0-identities) ![Discord](https://img.shields.io/discord/1173625923724124200?label=Discord&color=blue)

This gem can load and validate external identities

## Supported platforms

OAuth:
- Google
- Discord
- Microsoft
- Github
- Gitlab
- OIDC / oAuth2
- SAML

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
      redirect_uri: "http://localhost:8080/redirect",
      client_id: "id",
      client_secret: "xxxx"
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

# Configuration

As you already know, we allow / require to pass in a configuration. Here are all avaiable configuration keys:


## Oauth Based:
Here is the updated table where each key in the JSON (`identifier`, `username`, etc.) is explicitly labeled:

| Name                               | Description                                                                                | Default                                             |
|------------------------------------|--------------------------------------------------------------------------------------------|-----------------------------------------------------|
| `client_id`                        | The client id of the application (needs to be set)                                         | **(no default specified)**                          |
| `client_secret`                    | The client secret of the application (needs to be set)                                     | **(no default specified)**                          |
| `redirect_uri`                     | The redirect URL of the application (needs to be set)                                      | **(no default specified)**                          |
| `provider_name`                    | The provider name (not necessarily)                                                        | depends on the provider (e.g., `discord`, `github`) |
| `user_details_url`                 | The user details URL to gather user information (only for OIDC)                            | **(no default specified)**                          |
| `authorization_url`                | The URL which the user has to access to authorize (only for OIDC)                          | **(no default specified)**                          |
| `attribute_statements`             | The keys which the response of the user details has (id, name, email, ...) (only for OIDC) | `{}` (see below for more)                           |
| `attribute_statements.identifier`  | The identifier of the user to identify (only for OIDC)                                     | `["id", "sub", "identifier"]`                       |
| `attribute_statements.username`    | The username of the user (only for OIDC)                                                   | `["username", "name", "login"]`                     |
| `attribute_statements.email`       | The email address of the user (only for OIDC)                                              | `["email", "mail"]`                                 |
| `attribute_statements.firstname`   | The first name of the user (only for OIDC)                                                 | `["first_name", "firstname", ...]`                  |
| `attribute_statements.lastname`    | The last name of the user (only for OIDC)                                                  | `["last_name", "lastname", ...]`                    |

## SAML

| Name                             | Description                                                                                                                                                        | Default                            |
|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| `provider_name`                  | The provider name (not necessarily)                                                                                                                                | `saml`                             |
| `attribute_statements`           | The keys which the response of the user details has (id, name, email, ...) (only for OIDC)                                                                         | `{}` (see below for more)          |
| `attribute_statements.username`  | The username of the user                                                                                                                                           | `["username", "name", ...]`        |
| `attribute_statements.email`     | The email address of the user                                                                                                                                      | `["email", "mail", ...]`           |
| `attribute_statements.firstname` | The first name of the user                                                                                                                                         | `["first_name", "firstname", ...]` |
| `attribute_statements.lastname`  | The last name of the user                                                                                                                                          | `["last_name", "lastname", ...]`   |
| `settings`                       | The settings to configure the saml response/requests (see [SAML-Toolkits#L200](https://github.com/SAML-Toolkits/ruby-saml/blob/master/README.md?plain=1#L200))     | `{}`                               |
| `response_settings`              | The response settings to disable some checks if you want (see [SAML-Toolkits#L234](https://github.com/SAML-Toolkits/ruby-saml/blob/master/README.md?plain=1#L234)) | `{}`                               |
| `metadata_url`                   | The metadata url to fetch the metadatas (replacement for `settings`)                                                                                               | **(no default specified)**         |


