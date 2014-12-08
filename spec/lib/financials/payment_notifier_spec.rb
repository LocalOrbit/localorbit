describe Financials::PaymentNotifier do
  subject(:notifier) { described_class }

  describe ".seller_payment_received" do
    let(:m1) { Generate.market_with_orders }
    let(:seller) { m1[:seller_organizations].first }
    let(:users) { seller.users.each do |u| u.update(name: "Pug #{u.id}") end }
    let(:emails) { users.map(&:pretty_email) }
    let(:payment) { create(:payment, payee: seller) }

    let(:mailer) { ::PaymentMailer }
    let(:delayed_mailer) { double "Delayed Mailer" }

    it "invokes the PaymentMailer.payment_received in a delayed job for all users in the seller org" do
      expect(mailer).to receive(:delay).and_return(delayed_mailer)
      expect(delayed_mailer).to receive(:payment_received).with(emails, payment.id)

      notifier.seller_payment_received(payment: payment)
    end

    context "no payment" do
      it "does NOT send" do
        expect(mailer).not_to receive(:delay)
        notifier.seller_payment_received(payment: nil)
      end
    end

    context "when no users in seller org" do
      before do
        users.each do |u| u.destroy end
        seller.reload
      end

      it "does NOT send" do
        expect(mailer).not_to receive(:delay)
        notifier.seller_payment_received(payment: payment)
      end
    end
  end
end
