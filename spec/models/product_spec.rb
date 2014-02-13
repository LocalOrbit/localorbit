require 'spec_helper'

describe Product do
  describe "validations" do
    describe "organization" do
      let!(:buyer) { build(:organization, :buyer) }
      let!(:seller) { build(:organization, :seller) }

      it "is valid if the organization is a seller" do
        subject.organization = seller
        subject.valid?
        expect(subject.errors[:organization]).to be_empty
      end

      it "is invalid if the organization is not a seller" do
        subject.organization = buyer
        subject.valid?

        expect(subject.errors[:organization]).to include("must be able to sell products")
      end
    end
  end
end
