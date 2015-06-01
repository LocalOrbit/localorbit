require 'spec_helper'

describe Financials::PaymentNotifier do
  subject(:notifier) { described_class }

  context "payment notifications to Markets and Sellers" do
    let!(:m1) { Generate.market_with_orders }

    let(:seller) { m1[:seller_organizations].first }
    let(:seller_users) { seller.users.each do |u| u.update(name: "Pug #{u.id}") end }

    let(:mailer) { ::PaymentMailer }
    let(:delayed_mailer) { double "Delayed Mailer" }

    let(:market) { m1[:market] }
    let(:market_managers) { market.managers }


    # The seller and market notifiers are painfully similar.
    # Probably need to refactor and abstract.
    # But for now I've abstracted and parameterized the small test suite for each method:
    [
      [:seller_payment_received, :seller, :seller_users ],
      [:market_payment_received, :market, :market_managers ]
    ].each do |method_sym, payee_sym, users_sym|
      describe ".#{method_sym}" do
        let(:payee) { send(payee_sym) }
        let(:users) { send(users_sym) }

        let(:payment) { create(:payment, payee: payee) }
        let(:email_addresses) { users.map(&:pretty_email) }

        it "invokes the PaymentMailer.payment_received in a delayed job for all users in the seller org" do
          expect(mailer).to receive(:delay).and_return(delayed_mailer)
          expect(delayed_mailer).to receive(:payment_received).with(email_addresses, payment.id)

          notifier.send(method_sym, payment: payment)
        end

        context "with async:false" do
          let(:mail_object) { double "an email object" }

          it "delivers immediately, not via 'delay'" do
            expect(mailer).not_to receive(:delay)
            expect(mailer).to receive(:payment_received).with(email_addresses, payment.id).and_return(mail_object)
            expect(mail_object).to receive(:deliver)

            notifier.send(method_sym, payment: payment, async: false)
          end
        end

        context "no payment" do
          it "does NOT send" do
            expect(mailer).not_to receive(:delay)
            notifier.send(method_sym, payment: nil)
          end
        end

        context "when no users in seller org" do
          before do
            users.each do |u| u.destroy end
            payee.reload
          end

          it "does NOT send" do
            expect(mailer).not_to receive(:delay)
            notifier.send(method_sym, payment: payment)
          end
        end
      end # describe
     end # each
  end
end
