require "spec_helper"

describe OrderNumber do
  let(:market) { create(:market, subdomain: "fulton", timezone: "EST") }

  before do
    Timecop.freeze(Date.parse("2014-03-01"))
  end

  after do
    Timecop.return
  end

  describe "#id" do
    let(:order_number) { OrderNumber.new(market) }

    it "returns the next formatted order id based on year, market id, and sequence" do
      expect(order_number.id).to eq("LO-14-FULTON-0000001")
    end

    it "does not increment the id once requested" do
      Sequence.set_value_for!("order-14-FULTON", 5)
      expect(order_number.id).to eq("LO-14-FULTON-0000006")
      expect(order_number.id).to eq("LO-14-FULTON-0000006")
    end

    it "restarts the sequence when the year changes" do
      expect(order_number.id).to eq("LO-14-FULTON-0000001")
      Timecop.freeze(Date.parse("2015-03-01"))
      next_order = OrderNumber.new(market)
      expect(next_order.id).to eq("LO-15-FULTON-0000001")
    end

    it "sets the year based on the market's timezone" do
      Timecop.freeze("2015-01-01 00:00:00 EST")
      expect(order_number.id).to eq("LO-15-FULTON-0000001")
      market.update_attributes(timezone: "Hawaii")
      next_order = OrderNumber.new(market)
      expect(next_order.id).to eq("LO-14-FULTON-0000001")
    end
  end
end
