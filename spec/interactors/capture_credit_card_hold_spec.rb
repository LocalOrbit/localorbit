require "spec_helper"

describe CaptureCreditCardHold do
  let!(:market) { create(:market) }
  let!(:payment) { create(:payment, payment_type: "credit card", status: "pending", balanced_uri: "/hold_uri")}
  let(:balanced_debit) { double("balanced debit", uri: "/debit_uri", status: "succeeded") }
  let(:balanced_hold) { double("balanced hold", capture: balanced_debit, debit: nil) }

  subject { CaptureCreditCardHold.perform(payment: payment) }

  context "captures hold" do
    before do
      allow(Balanced::Hold).to receive(:find).and_return(balanced_hold)
    end
    it "updates the payment status" do
      subject

      expect(payment.reload.status).to eql("paid")
    end

    it "updates the uri to point to a debit" do
      subject

      expect(payment.reload.balanced_uri).to eql("/debit_uri")
    end
  end

  context "invalid hold" do
    before do
      allow(Balanced::Hold).to receive(:find).and_raise(RuntimeError)
    end

    it "fails" do
      expect(subject).to be_failure
    end

    it "sets an error message" do
      expect(subject.context[:error]).to eql("Unable to capture credit card funds")
    end
  end

  context "hold expired" do
    before do
      allow(Balanced::Hold).to receive(:find).and_return(balanced_hold)
      allow(balanced_hold).to receive(:capture).and_raise(RuntimeError)
    end

    it "fails" do
      expect(subject).to be_failure
    end

    it "sets an error message" do
      expect(subject.context[:error]).to eql("Unable to capture credit card funds")
    end
  end

  context "already captured" do
    let!(:balanced_hold) { double("balanced hold", capture: balanced_debit, debit: true) }

    before do
      allow(Balanced::Hold).to receive(:find).and_return(balanced_hold)
    end

    it "fails" do
      expect(subject).to be_failure
    end

    it "sets an error message" do
      expect(subject.context[:error]).to eql("Funds already captured from credit card")
    end
  end
end
