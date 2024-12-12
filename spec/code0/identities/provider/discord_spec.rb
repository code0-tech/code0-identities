# frozen_string_literal: true

RSpec.describe Code0::Identities::Provider::Discord do
  subject(:service_response) do
    described_class.new({
                          redirect_uri: redirect_uri,
                          client_id: client_id,
                          client_secret: client_secret
                        }).load_identity(code: code)
  end

  let(:redirect_uri) { SecureRandom.hex }
  let(:client_id) { SecureRandom.hex }
  let(:client_secret) { SecureRandom.hex }
  let(:code) { SecureRandom.hex }

  context "when code is invalid" do
    let(:response_body) { { error: "invalid_grant", error_description: "Invalid \"code\" in request." }.to_json }

    it "fails" do
      stub_request(:post, "https://discord.com/api/oauth2/token")
        .with(body: URI.encode_www_form({
                                          code: code,
                                          grant_type: "authorization_code",
                                          redirect_uri: redirect_uri,
                                          client_id: client_id,
                                          client_secret: client_secret
                                        }).to_s, headers: { "Content-Type" => "application/x-www-form-urlencoded" })
        .to_return(body: response_body, status: 400)

      expect { service_response }.to raise_error(Code0::Identities::Error, response_body)
    end
  end

  shared_examples "when everything is valid" do
    let(:access_token) { SecureRandom.hex }
    let(:response_body) { { id: 1, username: "name", email: "example@code0.tech" }.to_json }

    it "loads user identity" do
      stub_request(:post, "https://discord.com/api/oauth2/token")
        .with(body: URI.encode_www_form({
                                          code: code,
                                          grant_type: "authorization_code",
                                          redirect_uri: redirect_uri,
                                          client_id: client_id,
                                          client_secret: client_secret
                                        }).to_s, headers: { "Content-Type" => "application/x-www-form-urlencoded" })
        .to_return(body: { token_type: "Bearer",
                           access_token: access_token,
                           expires_in: 604_800,
                           refresh_token: "x",
                           scope: "openid identify email",
                           id_token: "x" }.to_json,
                   headers: { "Content-Type": "application/json" })

      stub_request(:get, "https://discord.com/api/users/@me")
        .with(headers: { "Authorization" => "Bearer #{access_token}" })
        .to_return(body: response_body, headers: { "Content-Type": "application/json" })

      expect(service_response.identifier).to eq(1)
      expect(service_response.provider).to eq("discord")
      expect(service_response.username).to eq("name")
      expect(service_response.email).to eq("example@code0.tech")
    end
  end

  context "when config is Proc" do
    subject(:service_response) do
      described_class.new(lambda {
                            {
                              redirect_uri: redirect_uri,
                              client_id: client_id,
                              client_secret: client_secret
                            }
                          }).load_identity(code: code)
    end

    it_behaves_like "when everything is valid"
  end

  context "when config is a hash" do
    it_behaves_like "when everything is valid"
  end
end
