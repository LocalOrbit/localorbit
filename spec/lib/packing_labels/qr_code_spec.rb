require "spec_helper"

describe PackingLabels::QrCode, wip:true do
  subject { described_class }
  include_context "the mini market"
  let(:order) {create(:order, organization: buyer_organization)}

  describe ".make_qr_code" do
    # it "gets an order's url" do 
    # end
  end

  describe ".get_order_url" do
    it "gets and order's url" do
      # expect(PackingLabels.get_order_url(order)).to eq order_path(order)
       # order_url = Rails.application.routes.url_helpers.order_path(host: host, order:order)
    end
  end

end
