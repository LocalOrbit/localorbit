require "spec_helper"

describe CreateStripeCustomerForEntity do

  before :all do
    VCR.turn_off!
  end

  after :all do
    VCR.turn_on!
  end

  after do
    cleanup_stripe_objects
  end


  context "integration tests" do
    subject { described_class }

    context "when Stripe customer doesn't yet exist for the entity" do
      let!(:org) { create(:organization, name: "Customer Creation Tests") }

      it "creates a new Stripe customer and associates it with the entity" do
        result = subject.perform(entity: org)

        expect(result.success?).to be true
        expect(org.stripe_customer_id).to be

        customer = Stripe::Customer.retrieve(org.stripe_customer_id)
        expect(customer).to be
        track_stripe_object_for_cleanup customer
        expect(customer.description).to eq org.name
        expect(customer.metadata["lo_entity_type"]).to eq 'organization'
        expect(customer.metadata["lo_entity_id"]).to eq org.id.to_s
      end
    end

    context "when Stripe customer already associated with the entity" do
      let!(:org) { create(:organization, name: "[Test] Customer Creation") }

      it "keeps the existing customer" do
        # Setup a customer:
        result = subject.perform(organization: org) # :organization is an allowable alternative key in the context

        # Peek, see it's good:
        expect(org.stripe_customer_id).to be
        customer = Stripe::Customer.retrieve(org.stripe_customer_id)
        expect(customer).to be
        track_stripe_object_for_cleanup customer

        # Remember the id:
        existing_customer_id = org.stripe_customer_id

        # DO AGAIN:
        result2 = subject.perform(entity: org)
        expect(result.success?).to be true

        expect(result.success?).to be true
        if org.stripe_customer_id != existing_customer_id
          customer2 = Stripe::Customer.retrieve(org.stripe_customer_id)
          p customer2
          track_stripe_object_for_cleanup customer2
        end
        expect(org.stripe_customer_id).to eq existing_customer_id 
      end
    end
  end
end
