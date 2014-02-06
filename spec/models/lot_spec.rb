require 'spec_helper'

describe Lot do
  it "is valid with only a quantity" do
    subject.quantity = 12
    expect(subject).to be_valid
  end

  describe "Validations for" do
    describe "quantity:" do
      it "has errors when none is specified" do
        expect(subject).to_not be_valid
        expect(subject).to have(1).errors_on(:quantity)
      end
    end

    describe "number:" do
      context "when expiration_date is given" do
        it "has errors when number is not given" do
          subject.expires_at = 2.days.from_now
          expect(subject).to_not be_valid
          expect(subject.errors_on(:number)).to include("can't be blank when 'Expiration Date' is present")
        end
      end
    end

    describe "expires_at:" do
      before do
        subject.quantity = 12
        subject.number = 2
      end

      context "when creating the lot" do
        it "is valid when expires_at is in the future" do
          subject.expires_at = 2.days.from_now
          expect(subject).to be_valid
        end

        it "has errors when expires_at is in the past" do
          subject.expires_at = 2.days.ago
          expect(subject).to be_invalid
          expect(subject.errors_on(:expires_at)).to include("must be in the future")
        end
      end

      context "when updating the lot" do
        before { subject.save }

        it "is valid when expires_at occurs after created_at" do
          subject.expires_at = 2.days.from_now
          expect(subject).to be_valid
        end

        it "has errors when expires_at occurs before created_at" do
          subject.expires_at = 2.days.ago
          expect(subject).to be_invalid
          expect(subject.errors_on(:expires_at)).to include("must be after #{Time.now.strftime("%m/%d/%Y")}")
        end
      end
    end

    describe "good_from:" do
      it "has errors if it is greater than the expiration date" do
        subject.expires_at = 1.day.from_now
        subject.good_from = 3.days.from_now

        expect(subject).to be_invalid
        expect(subject.errors_on(:good_from)).to include("cannot be after expires at date")
      end
    end
  end

end
