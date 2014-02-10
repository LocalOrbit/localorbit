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

  describe '#simple_inventory' do
    before do
      subject.use_simple_inventory = true
    end

    it 'returns 0 for a new product' do
      expect(subject.simple_inventory).to eq(0)
    end

    it 'does not return the quantity of an expired lot' do
      subject.lots.build(number: '1', expires_at: 2.days.ago, quantity: 42)
      expect(subject.simple_inventory).to eq(0)
    end

    it 'returns the available inventory for the product' do
      subject.lots.build(quantity: 42)
      expect(subject.simple_inventory).to eq(42)
    end
  end

  describe "#simple_inventory=" do

    it "sets errors for negative numbers" do
      subject.simple_inventory = -10
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to include("Simple inventory quantity must be greater than or equal to 0")
    end


    context "use_simple_inventory is set" do
      describe "on create" do
        subject { build(:product, use_simple_inventory: true) }

        before do
          subject.simple_inventory = "42"
        end

        it "creates a new lot with the assigned quantity" do
          expect {
            subject.save
          }.to change {
            Lot.where(product_id: subject.id).count
          }.from(0).to(1)
        end

        it "new lot has assigned quantity" do
          expect(subject.lots.last.quantity).to eq(42)
        end
      end

      describe "on update" do
        subject { create(:product, use_simple_inventory: true) }

        it "updates the newest lot with the assigned quantity" do
          subject.lots.create!(number: '1', expires_at: 1.day.from_now, quantity: 0, created_at: 3.days.ago)
          simple_lot = subject.lots.create!(quantity: 12)
          subject.simple_inventory = 42

          expect {
            subject.save!
          }.to change {
            Lot.find(simple_lot.id).quantity
          }.from(12).to(42)
        end

        it "create a new lot if one doesn't exist" do
          subject.simple_inventory = 42
          expect {
            subject.save
          }.to change {
            Lot.where(product_id: subject.id).count
          }.from(0).to(1)
        end

        it "sets the quantity on the new lot to the assigned quantity" do
          subject.simple_inventory = 42
          subject.save
          expect(subject.lots(true).last.quantity).to eq(42)
        end
      end
    end

    context "use_simple_inventory is not set" do
      before do
        subject.use_simple_inventory = false
      end

      context "new record" do
        subject{ build(:product, use_simple_inventory: false) }

        it "does not create a new lot" do
          subject.simple_inventory = '6'
          expect {
            subject.save
          }.to_not change{
            Lot.count
          }
        end
      end

      context "existing record" do
        subject{ create(:product, use_simple_inventory: false) }

        context "with no lots" do
          it "does not create a new lot" do
            subject.simple_inventory = '6'
            expect {
              subject.save
            }.to_not change{
              Lot.count
            }
          end
        end

        context "with existing lots" do
          before do
            subject.lots.create(quantity: 12)
            subject.simple_inventory = '6'
            subject.save!
          end

          it "does not create any lots" do
            expect(Lot.count).to eq(1)
          end

          it "does not update any lots" do
            expect(Lot.first.quantity).to eq(12)
          end
        end
      end
    end
  end
end
