require 'spec_helper'

describe QrCodeController do
  include_context "the mini market" 

  let!(:product1) { create(:product, :sellable, organization: seller_organization) }
  let!(:order_item1) { create(:order_item, product: product1) }
  let!(:order) { create(:order, items: [order_item1], market: mini_market, organization: buyer_organization) }

  let(:host) { "http://#{order.market.subdomain}.#{Figaro.env.domain}" }

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in user
    switch_to_subdomain "app"
  end

  def hit_qr_code_url
    get :order, id: order.id
  end

  def see_redirected_to_buyer_order_url
    expect(response).to redirect_to(order_url(host: host, id: order.id))
  end

  def see_redirected_to_admin_order_url
    expect(response).to redirect_to(admin_order_url(host: host, id: order.id))
  end

  describe "#order" do
    context "logged in as a buyer" do
      let(:user) { barry }

      it "redirects to the correct order url on the correct subdomain" do
        hit_qr_code_url
        see_redirected_to_buyer_order_url
      end
    end

    context "logged in as a seller" do
      let(:user) { sally }

      it "redirects to the correct order url on the correct subdomain" do
        hit_qr_code_url
        see_redirected_to_admin_order_url
      end
    end

    context "logged in as a market manager" do
      let(:user) { mary }

      it "redirects to the correct order url on the correct subdomain" do
        hit_qr_code_url
        see_redirected_to_admin_order_url
      end
    end

    context "logged in as an admin" do
      let(:user) { aaron }

      it "redirects to the correct order url on the correct subdomain" do
        hit_qr_code_url
        see_redirected_to_admin_order_url
      end
    end
  end
end

