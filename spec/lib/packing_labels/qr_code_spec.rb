require "spec_helper"

describe PackingLabels::QrCode do
  subject { described_class }

  describe ".make_qr_code" do
    let(:order) { create(:order) }
    let(:in_host) { "http://webs.example.com" }
    let(:used_host) { "http://app.example.com" }
    let(:order_url) { Rails.application.routes.url_helpers.qr_code_url(host:used_host, id:order.id) }

    it "gets and order's url" do
      qr_code_url = subject.make_qr_code(order, host:in_host)
      expect(qr_code_url).to match(/chl=#{Rack::Utils.escape(order_url)}/)
      expect(qr_code_url).to match(/http:\/\/chart.apis.google.com\/chart\?/)
      puts qr_code_url
    end
  end


  describe ".google_qr_code_url_for" do
    let(:content_url) { "http://localorbit.com/admin/orders/0?thinger" }
    let(:escaped_content_url) { Rack::Utils.escape(content_url) }

    it "generates a Google Charts QR code URI by URL-escaping our content" do
      qr_code_url = subject.google_qr_code_url_for(content_url)
      expect(qr_code_url).to match(/chl=#{escaped_content_url}/)
      expect(qr_code_url).to match(/http:\/\/chart.apis.google.com\/chart\?/)
    end
  end

end
