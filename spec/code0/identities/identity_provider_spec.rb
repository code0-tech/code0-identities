# frozen_string_literal: true

RSpec.describe Code0::Identities::IdentityProvider do
  let(:instance) do
    described_class.new
  end

  describe "#add_provider" do
    it "adds the correct class" do
      instance.add_provider :google, {}
      expect(instance.providers).to match(google: an_instance_of(Code0::Identities::Provider::Google))
    end
  end

  describe "#load_identity" do
    it "calls the right provider" do
      provider = Code0::Identities::Provider::Google.new({})
      allow(provider).to receive(:load_identity)
      instance.providers[:google] = provider
      instance.load_identity(:google, { test: 1 })
      expect(provider).to have_received(:load_identity).with({ test: 1 })
    end
  end
end
