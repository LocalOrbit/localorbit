require "spec_helper"

describe CreateBalancedCustomerForEntity do
  context "balanced customer doesn't exist" do
    let!(:entity) { create(:organization, name: "Fake Organization") }

    subject { CreateBalancedCustomerForEntity.perform(entity: entity) }

    it "creates a balanced customer" do
      expect(Balanced::Customer).to receive(:new).and_return(double("Balanced Customer", save: double("Balanced Customer", uri: "/balanced-customer-uri")))

      expect {
        subject
      }.to change {
        entity.balanced_customer_uri
      }.from(nil).to("/balanced-customer-uri")
    end
  end
  context "balanced customer already exists" do
    let!(:entity) { create(:organization, name: "Fake Organization", balanced_customer_uri: "/existing-balanced-customer") }

    subject { CreateBalancedCustomerForEntity.perform(entity: entity) }

    it "does not create a balanced customer" do
      expect(Balanced::Customer).to_not receive(:new)

      expect {
        subject
      }.to_not change {
        entity.balanced_customer_uri
      }.from("/existing-balanced-customer")
    end
  end
end
