require "spec_helper"

describe NonMarketDomain do
  let(:base_domain) { Figaro.env.domain }
  let(:request) { double("request") }
  let(:constraint) { NonMarketDomain.new }

  context "#matches?" do
    it "returns false if the request domain is the base domain" do
      allow(request).to receive(:subdomains)
      allow(request).to receive(:host).and_return(base_domain)

      expect(constraint.matches?(request)).to be(false)
    end

    it "returns false if the subdomain is the 'app' subdomain" do
      allow(request).to receive(:subdomains).and_return(["app"])
      allow(request).to receive(:host).and_return("app.#{base_domain}")

      expect(constraint.matches?(request)).to be(false)
    end

    it "returns false if the subdomain is a market subdomain" do
      allow(request).to receive(:subdomains).and_return(["real"])
      allow(request).to receive(:host).and_return("real.#{base_domain}")
      allow(constraint).to receive(:market_exists?).with("real").and_return(true)

      expect(constraint.matches?(request)).to be(false)
    end

    it "returns true if the subdomain is not a market subdomain" do
      allow(request).to receive(:subdomains).and_return(["fake"])
      allow(request).to receive(:host).and_return("fake.#{base_domain}")
      allow(constraint).to receive(:market_exists?).with("fake").and_return(false)

      expect(constraint.matches?(request)).to be(true)
    end

    it "returns true if the request domain is an unknown domain" do
      allow(request).to receive(:subdomains)
      allow(request).to receive(:host).and_return("example.com")

      expect(constraint.matches?(request)).to be(true)
    end
  end
end
