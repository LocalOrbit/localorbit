require "spec_helper"
require "ostruct"

describe UnderwriteEntity do
  subject(:interactor) { UnderwriteEntity.new(balanced_customer: balanced_customer, representative_params: representative_params, entity: org) }

  let(:org) { create(:organization, name: "Our Org") }
  let(:balanced_customer) { OpenStruct.new }

  describe "#perform" do
    let(:representative_params) do
      {
        name: "John Doe",
        ssn_last4: "1234",
        dob: {
          year: "1982",
          month: "09"
        },
        address: {
          line1: "1234 Fake St",
          postal_code: "12345"
        }
      }
    end

    context "when organization is already underwritten" do
      before do
        allow(org).to receive(:balanced_underwritten?) { true }
      end

      it "does nothing" do
        expect(interactor).not_to receive(:update_balanced_customer_info)

        interactor.perform
      end
    end

    context "when organization is not already underwritten" do
      before do
        allow(balanced_customer).to receive(:is_identity_verified?) { true }
        allow(balanced_customer).to receive(:save) { balanced_customer }
      end

      it "updates the balanced customer w/ business info if ein is provided" do
        representative_params.merge!(ein: "20-1234567")

        interactor.perform

        expect(balanced_customer.name).to eq("John Doe")
        expect(balanced_customer.ssn_last4).to eq("1234")
        expect(balanced_customer.dob).to eq("1982-09")
        expect(balanced_customer.address).to eq(line1: "1234 Fake St", postal_code: "12345")
        expect(balanced_customer.ein).to eq("201234567")
        expect(balanced_customer.business_name).to eq("Our Org")
      end

      it "updates the balanced customer w/o business info if ein is not provided" do
        interactor.perform

        expect(balanced_customer.name).to eq("John Doe")
        expect(balanced_customer.ssn_last4).to eq("1234")
        expect(balanced_customer.dob).to eq("1982-09")
        expect(balanced_customer.address).to eq(line1: "1234 Fake St", postal_code: "12345")
        expect(balanced_customer.ein).to be_nil
        expect(balanced_customer.business_name).to be_nil
      end

      it "updates the organization's balanced_underwritten status" do
        expect {
          interactor.perform
        }.to change {
          org.balanced_underwritten?
        }.from(false).to(true)
      end

      context "without underwritting params" do
        let(:representative_params) do
          {
            name: "",
            ssn_last4: "",
          }
        end

        it "does not attempt underwritting" do
          expect(Balanced::Customer).to_not receive(:find)

          interactor.perform

          expect(interactor.representative_params[:name]).to be_nil
          expect(interactor.representative_params[:ssn_last_4]).to be_nil
        end
      end
    end
  end
end
