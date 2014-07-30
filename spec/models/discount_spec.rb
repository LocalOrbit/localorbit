require 'spec_helper'

describe Discount do
  context "validations" do
    it "requires a name" do
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a code" do
      expect(subject).to have(1).error_on(:code)
    end

    it "requires code to be unique" do
      first = create(:discount)
      subject.code = first.code
      expect(subject).to have(1).error_on(:code)
    end

    it "requires a type" do
      expect(subject).to have(1).error_on(:type)
    end

    context "valid types" do
      it "allows a type of 'fixed'" do
        subject.type = "fixed"
        expect(subject).to have(0).errors_on(:type)
      end

      it "allows a type of 'percentage'" do
        subject.type = "percentage"
        expect(subject).to have(0).errors_on(:type)
      end
    end

    context "date range" do
      it "requires end date to be after start date" do
        subject.end_date = 1.day.from_now
        subject.start_date = 2.days.from_now

        expect(subject).to have(1).errors_on(:end_date)
      end

      it "requires start date to be set if end date is set" do
        subject.end_date = 1.day.from_now

        expect(subject).to have(1).errors_on(:end_date)
      end

      it "allows both to be blank" do
        expect(subject).to have(0).errors_on(:end_date)
      end

      context "on create" do
        it "does not allow end_dates in the past" do
          subject.start_date = 2.days.ago
          subject.end_date   = 1.day.ago

          expect(subject).to have(1).errors_on(:end_date)
        end
      end

      context "on update" do
        it "ignores the end_date" do
          subject = create(:discount)
          subject.start_date = 2.days.ago
          subject.end_date   = 1.day.ago
          subject.save!(validate: false)
          subject.reload

          expect(subject).to have(0).errors_on(:end_date)
        end

        it "validates the end_date if it has changed" do
          subject = create(:discount)
          subject.start_date = 2.days.ago
          subject.end_date   = 1.day.ago
          subject.save!(validate: false)
          subject.reload

          subject.end_date = 1.hour.ago
          expect(subject).to have(1).errors_on(:end_date)
        end
      end
    end

    it "requires discount to be between 0 and 2_147_483_647" do
      subject.discount = -1
      expect(subject).to have(1).errors_on(:discount)

      subject.discount = 2_147_483_648
      expect(subject).to have(1).errors_on(:discount)
    end


    it "requires minimum_order_total to be between 0 and 2_147_483_647" do
      subject.minimum_order_total = -1
      expect(subject).to have(1).errors_on(:minimum_order_total)

      subject.minimum_order_total = 2_147_483_648
      expect(subject).to have(1).errors_on(:minimum_order_total)
    end

    it "requires maximum_order_total to be between 0 and 2_147_483_647" do
      subject.maximum_order_total = -1
      expect(subject).to have(1).errors_on(:maximum_order_total)

      subject.maximum_order_total = 2_147_483_648
      expect(subject).to have(1).errors_on(:maximum_order_total)
    end

    it "requires maximum_uses to be between 0 and 2,147,483,647" do
      subject.maximum_uses = -1
      expect(subject).to have(1).errors_on(:maximum_uses)

      subject.maximum_uses = 2_147_483_648
      expect(subject).to have(1).errors_on(:maximum_uses)
    end

    it "requires maximum_organization_uses to be between 0 and 2,147,483,647" do
      subject.maximum_organization_uses = -1
      expect(subject).to have(1).errors_on(:maximum_organization_uses)

      subject.maximum_organization_uses = 2_147_483_648
      expect(subject).to have(1).errors_on(:maximum_organization_uses)
    end
  end

  describe "#total_uses" do
    let!(:discount) { create(:discount) }
    let!(:order1)   { create(:order, discount: discount) }
    let!(:order2)   { create(:order, discount: discount) }
    let!(:order3)   { create(:order) }

    it "returns a count of the times the discount has been used" do
      expect(discount.total_uses).to eql(2)
    end
  end

  describe "#uses_by_organization" do
    let!(:organization) { create(:organization) }
    let!(:discount)     { create(:discount) }
    let!(:order1)       { create(:order, discount: discount, organization: organization) }
    let!(:order2)       { create(:order, discount: discount) }
    let!(:order3)       { create(:order) }

    it "returns a count of the times the discount has been used" do
      expect(discount.uses_by_organization(organization)).to eql(1)
    end
  end
end
