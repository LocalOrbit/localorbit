require "spec_helper"

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

      it "has errors if the quantity is negative" do
        subject.quantity = -3
        expect(subject.errors_on(:quantity)).to include("must be greater than or equal to 0")
      end

      it "requires the quantity to be less than a million" do
        subject.quantity = 1_000_000
        expect(subject).to have(1).error_on(:quantity)
      end
    end

    describe "number:" do
      context "when expiration_date is given" do
        it "has errors when number is not given" do
          subject.expires_at = 2.days.from_now
          expect(subject).to_not be_valid
          expect(subject.errors.full_messages).to include("Lot # can't be blank when 'Expiration Date' is present")
        end
      end

      it "unique across a product" do
        product1 = create(:product)
        product2 = create(:product)

        create(:lot, product: product1, number: "ABC")

        lot = build(:lot, product: product1, number: "ABC")
        expect(lot).to have(1).errors_on(:number)

        lot = build(:lot, product: product2, number: "ABC")
        expect(lot).to have(0).errors_on(:number)
      end

      it "allows muliple unnamed lots" do
        product1 = create(:product)

        create(:lot, product: product1, number: nil)

        lot = build(:lot, product: product1, number: nil)
        expect(lot).to have(0).errors_on(:number)
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
          expect(subject.errors.full_messages).to include("Expires On must be in the future")
        end
      end

      context "when updating the lot" do
        before { subject.save! }

        it "is valid when expires_at occurs after created_at" do
          subject.expires_at = 2.days.from_now
          expect(subject).to be_valid
        end

        it "has errors when expires_at occurs before created_at" do
          subject.expires_at = 2.days.ago
          expect(subject).to be_invalid
          expect(subject.errors_on(:expires_at)).to include("must be after #{Time.zone.now.strftime("%m/%d/%Y")}")
        end
      end
    end

    describe "good_from:" do
      it "has errors if it is greater than the expiration date" do
        subject.expires_at = 1.day.from_now
        subject.good_from = 3.days.from_now

        expect(subject).to be_invalid
        expect(subject.errors.full_messages).to include("Good From cannot be after expires at date")
      end
    end
  end

  describe "available scope" do
    let(:product) { create(:product) }

    it "returns current lots" do
      expect {
        product.lots.create!(quantity: 12)
        product.lots.create!(quantity: 12, number: "1", expires_at: 1.day.from_now)
        product.lots.create!(quantity: 12, number: "2", good_from: 1.day.ago)
        product.lots.create!(quantity: 12, number: "3", good_from: 1.day.ago, expires_at: 1.day.from_now)
        product.lots.create!(quantity: 12, number: "4", good_from: 1.day.ago, expires_at: 2.days.from_now)
      }.to change {
        Lot.available.count
      }.from(0).to(5)
    end

    it "returns lots available at the requested date" do
      expect {
        product.lots.create!(quantity: 12)
        product.lots.create!(quantity: 12, number: "1", expires_at: 1.day.from_now)
        product.lots.create!(quantity: 12, number: "2", good_from: 1.day.ago)
        product.lots.create!(quantity: 12, number: "3", good_from: 1.day.ago, expires_at: 1.day.from_now)
        product.lots.create!(quantity: 12, number: "4", good_from: 1.day.ago, expires_at: 2.days.from_now)
      }.to change {
        Lot.available(1.day.from_now).count
      }.from(0).to(3)
    end

    it "excludes expired lots" do
      expect {
        lot = product.lots.create!(quantity: 12, number: "1", expires_at: 1.day.from_now)
        lot.update_attribute(:expires_at, 1.day.ago)
      }.to_not change {
        Lot.available.count
      }
    end

    it "excludes lots from the future" do
      expect {
        lot = product.lots.create!(quantity: 12, number: "1", good_from: 1.day.from_now, expires_at: 2.day.from_now)
      }.to_not change {
        Lot.available.count
      }
    end

    it "returns available lots, oldest first" do
      product.lots.create!(quantity: 12)
      product.lots.create!(quantity: 12, number: "1", expires_at: 1.day.from_now)
      product.lots.create!(quantity: 12, number: "2", good_from: 1.day.ago)
      product.lots.create!(quantity: 12, number: "3", good_from: 1.day.ago, expires_at: 1.day.from_now)
      product.lots.create!(quantity: 12, number: "4", good_from: 1.day.ago, expires_at: 2.days.from_now)

      expect(product.lots_by_expiration.available(1.day.from_now).first.number).to eql("4")
    end

  end

  describe "#available_inventory" do
    before do
      subject.quantity = 42
    end

    context "without expiration" do
      it "returns the set quantity" do
        expect(subject.available_quantity).to eq(42)
      end
    end

    context "with a current good from date" do
      it "returns the set quantity" do
        subject.good_from = 1.day.ago
        expect(subject.available_quantity).to eq(42)
      end
    end

    context "with a future good from date" do
      it "returns 0" do
        subject.good_from = 1.day.from_now
        expect(subject.available_quantity).to eq(0)
      end
    end

    context "with a future expiration date" do
      it "returns the given quantity" do
        subject.expires_at = 1.day.from_now
        expect(subject.available_quantity).to eq(42)
      end
    end

    context "with a past expiration date" do
      it "returns 0" do
        subject.expires_at = 1.day.ago
        expect(subject.available_quantity).to eq(0)
      end
    end
  end

  describe "#available?" do
    it "is true if good_from and expires_at are nil or appropriate values" do
      subject.good_from = nil
      subject.expires_at = nil
      expect(subject).to be_available

      subject.good_from = 1.day.ago
      expect(subject).to be_available

      subject.expires_at = 1.day.from_now
      expect(subject).to be_available

      subject.good_from = nil
      expect(subject).to be_available
    end

    it "is false if good_from is in the future" do
      subject.good_from = 1.day.from_now
      subject.expires_at = nil
      expect(subject).to_not be_available

      subject.expires_at = 2.days.from_now
      expect(subject).to_not be_available
    end

    it "is false if expires at is in the past" do
      subject.expires_at = 1.day.ago
      expect(subject).to_not be_available
    end
  end

  describe "#simple?" do
    it "is true if number, good_from, and expires_at are not set" do
      subject.number = nil
      subject.good_from = nil
      subject.expires_at = nil

      expect(subject).to be_simple
    end

    it "is false if number, good_from, or expires_at are set" do
      subject.number = "1"
      subject.good_from = nil
      subject.expires_at = nil
      expect(subject).to_not be_simple

      subject.number = nil
      subject.good_from = 1.day.from_now
      expect(subject).to_not be_simple

      subject.good_from = nil
      subject.expires_at = 1.day.from_now
      expect(subject).to_not be_simple

      subject.number = '1'
      subject.good_from = 1.day.from_now
      subject.expires_at = 2.days.from_now
      expect(subject).to_not be_simple
    end
  end
end
