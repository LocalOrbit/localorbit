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

  describe "default values" do
    describe "#top_level_category_id" do
      let(:org) { create(:organization) }
      let(:top_level) { create(:category, parent: Category.root) }
      let!(:category) { create(:category, parent: top_level) }
      subject { Product.create!(short_description: "desc", name: "New Product", organization: org, category: category) }

      it "assigns the top level based on category" do
        expect(subject.top_level_category).to eql(top_level)
      end
    end
  end

  describe ".available_for_market" do
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }
    let(:product3) { create(:product) }

    let(:market) { double("Market", organization_ids: [product1.organization_id, product2.organization_id]) }

    it "returns products in the user's market" do
      expect(Product.available_for_market(market)).to match_array([product1, product2])
    end

    it "returns empty active record relation if market is nil" do
      results = Product.available_for_market(nil)

      expect(results).to be_a(ActiveRecord::Relation)
      expect(results).to be_empty
    end
  end

  it ".available_for_sale contains the correct products" do
    market      = create(:market)
    market2     = create(:market)
    org_in      = create(:organization, markets: [market])
    org_out     = create(:organization)
    buyer       = create(:organization, markets: [market])
    other_buyer = create(:organization, markets: [market])

    product_in                    = create(:product, organization: org_in)
    product_out                   = create(:product, organization: org_out)
    product_in_no_price           = create(:product, organization: org_in)
    product_in_no_lot             = create(:product, organization: org_in)
    product_in_other_buyer_price  = create(:product, organization: org_in)
    product_in_other_market_price = create(:product, organization: org_in)

    create(:price, product: product_in)
    create(:price, product: product_out)
    create(:price, product: product_in_no_lot)
    create(:price, product: product_in_other_buyer_price, organization: other_buyer)
    create(:price, product: product_in_other_market_price, market: market2)

    create(:lot, product: product_in)
    create(:lot, product: product_out)
    create(:lot, product: product_in_no_price)
    create(:lot, product: product_in_other_buyer_price)
    create(:lot, product: product_in_other_market_price)

    expect(Product.available_for_sale(market, buyer)).to eq([product_in])
  end

  describe ".for_organization_id" do
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }

    it "returns products sold by organization" do
      expect(Product.for_organization_id(product1.organization_id)).to match_array([product1])
    end
  end

  describe '#can_use_simple_inventory?' do
    let(:product) { create(:product, use_simple_inventory: false) }

    it "is true if they are using simple inventory" do
      product.use_simple_inventory = true
      product.lots.create!(quantity: 10)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is true if all lots have expired" do
      lot = product.lots.create!(quantity: 2, number: '1')
      lot.update_attribute(:expires_at, 1.day.ago)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is true if all non-expired lots have no quantity" do
      product.lots.create!(quantity: 0, number: '1')
      product.lots.create!(quantity: 0, number: '1', expires_at: 2.days.from_now)
      product.lots.create!(quantity: 0, number: '1', good_from: 1.day.from_now, expires_at: 2.days.from_now)

      expect(product.can_use_simple_inventory?).to be true
    end

    it "is false if any lots with quantity have not expired" do
      product.lots.create!(quantity: 10, number: '1', expires_at: 2.days.from_now)

      expect(product.can_use_simple_inventory?).to be false
    end

    it "is false if any lots have a quantity" do
      product.lots.create!(quantity: 10, number: '1')

      expect(product.can_use_simple_inventory?).to be false
    end

    it "is false if any future lots have a quantity" do
      product.lots.create!(quantity: 10, number: '1', good_from: 1.day.from_now)

      expect(product.can_use_simple_inventory?).to be false
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
            subject.save!
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
            subject.save!
          }.to change {
            Lot.where(product_id: subject.id).count
          }.from(0).to(1)
        end

        it "sets the quantity on the new lot to the assigned quantity" do
          subject.simple_inventory = 42
          subject.save!
          expect(subject.lots(true).last.quantity).to eq(42)
        end

        it "does not use a lot with a future good from date" do
          subject.lots.create!(number: '1', created_at: 1.minute.ago, good_from: 1.day.from_now, expires_at: 2.days.from_now, quantity: 0)

          expect {
            subject.simple_inventory = 42
            subject.save!
          }.to change {
            Lot.where(product_id: subject.id).count
          }.by(1)

          lot = subject.lots(true).last
          expect(lot.quantity).to eq(42)
          expect(lot.number).to be_nil
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
            subject.save!
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
              subject.save!
            }.to_not change{
              Lot.count
            }
          end
        end

        context "with existing lots" do
          before do
            subject.lots.create!(quantity: 12)
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

  describe '#available_inventory' do
    context 'using simple inventory' do
      context 'with no inventory set' do
        subject { create(:product, use_simple_inventory: true) }

        it 'returns 0' do
          expect(subject.available_inventory).to eq(0)
        end
      end

      context 'with inventory set' do
        subject { create(:product, use_simple_inventory: true, simple_inventory: 42) }

        it 'returns simple inventory quantity' do
          expect(subject.available_inventory).to eq(42)
        end
      end
    end

    context 'using advanced inventory' do
      subject { create(:product, use_simple_inventory: false) }

      context 'with no inventory set' do
        it 'returns 0' do
          expect(subject.available_inventory).to eq(0)
        end
      end

      context 'with available inventory lots' do
        before do
          subject.lots.create!(quantity: 42)
          subject.lots.create!(quantity: 24)
        end

        it 'returns the sum of the available lot inventory' do
          expect(subject.available_inventory).to eq(66)
        end

        context 'that are expired' do
          before do
            lot = subject.lots.create!(created_at: 2.days.ago, number: '1', expires_at: 1.minute.from_now, quantity: 50)
            lot.update_attribute(:expires_at, 1.day.ago)
          end

          it 'returns the sum of the available lot inventory' do
            expect(subject.available_inventory).to eq(66)
          end
        end

        context 'that have not reached their good_from date' do

          before do
            lot = subject.lots.create!(created_at: 2.days.ago, number: '1', good_from: 2.days.from_now, expires_at: 1.week.from_now, quantity: 50)
          end

          it 'returns the sum of the available lot inventory' do
            expect(subject.available_inventory).to eq(66)
          end
        end
      end
    end
  end
end
