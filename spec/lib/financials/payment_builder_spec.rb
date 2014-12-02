describe Financials::PaymentBuilder do
  subject(:payment_builder) { described_class }

  describe ".payment_to_seller" do
    let(:m1) { Generate.market_with_orders }
    let(:seller) { m1[:seller_organizations][0] }
    let(:bank_account) { seller.bank_accounts.first }
    let(:amount) { 42.to_d }
    let(:market) { m1[:market] }
    let(:orders) { m1[:orders] }

    let(:payment_info) {{
      payee: seller,
      bank_account: bank_account,
      amount: amount,
      market: market,
      orders: orders
    }}

    it "creates a new Payment record by attaching appropriate payment type and method to the base info" do
      payment = payment_builder.payment_to_seller(payment_info: payment_info)

      expect(payment.payment_type).to eq "seller payment"
      expect(payment.payment_method).to eq "ach"
      expect(payment.status).to eq "pending"

      expect(payment.payee).to eq seller
      expect(payment.bank_account).to eq bank_account
      expect(payment.amount).to eq amount
      expect(payment.market).to eq market
      expect(payment.orders).to contain_exactly(*orders)
      
      # See this thing's actually in the DB
      p2 = Payment.find(payment.id)
      expect(p2).to eq(payment)

    end

  end
end
