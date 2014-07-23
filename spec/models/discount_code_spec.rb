require 'spec_helper'

describe DiscountCode do
  context "validations" do
    it "requires a name" do
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a code" do
      expect(subject).to have(1).error_on(:code)
    end

    it "requires a type" do
      expect(subject).to have(2).error_on(:type)
    end

    context "valid types" do
      it "allows a type of 'fixed'" do
        subject.type = 'fixed'
        expect(subject).to have(0).errors_on(:type)
      end

      it "allows a type of 'percentage'" do
        subject.type = 'percentage'
        expect(subject).to have(0).errors_on(:type)
      end
    end

    context "date range" do
      it "requires end date to be after start date" do
        subject.end_date = Date.current
        subject.start_date = 2.days.from_now

        expect(subject).to have(1).errors_on(:end_date)
      end

      it "requires start date to be set if end date is set" do
        subject.end_date = Date.current

        expect(subject).to have(1).errors_on(:end_date)
      end

      it "allows both to be blank" do
        expect(subject).to have(0).errors_on(:end_date)
      end
    end
  end
end
