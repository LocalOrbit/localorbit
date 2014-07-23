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
  end
end
