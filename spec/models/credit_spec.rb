require "spec_helper"

describe Credit do
  let!(:order) {create(:order, :with_items, payment_method: "purchase order")}
  let!(:credit) {create(:credit, order: order, amount: 1)}

  it "requires an order, user, amount type, payer type, and amount" do
    expect(credit).to be_valid
    credit.order = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:order)
    credit.reload
    credit.user = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:user)
    credit.reload
    credit.amount_type = nil
    expect(credit).to_not be_valid
    expect(credit).to have(2).error_on(:amount_type)
    credit.reload
    credit.payer_type = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:payer_type)
    credit.reload
    credit.amount = nil
    expect(credit).to_not be_valid
    expect(credit).to have(2).error_on(:amount)
    credit.reload
  end

  it "only allows two possible types in 'amount_type'" do
    expect(credit).to be_valid
    credit.amount_type = "cat"
    expect(credit).to_not be_valid
    credit.reload
    credit.amount_type = Credit::PERCENTAGE
    expect(credit).to be_valid
    credit.reload
    credit.amount_type = Credit::FIXED
    expect(credit).to be_valid
  end

  it "only allows two possible types in 'payer_type'" do
    expect(credit).to be_valid
    credit.payer_type = "cat"
    expect(credit).to_not be_valid
    credit.reload
    credit.payer_type = Credit::MARKET
    expect(credit).to be_valid
    credit.reload
    credit.payer_type = Credit::ORGANIZATION
    expect(credit).to be_valid
  end

  it "cannot be created for any order not paid by purchase order" do
    order.payment_method = "credit card"
    order.save
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:order)
  end

  describe "amount" do
    it "cannot exceed the order total" do
      order.update_column(:total_cost, 200)
      credit.amount = 210
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
      credit.amount_type = Credit::PERCENTAGE
      credit.amount = 120
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
    end

    it "cannot exceed the total for any specific supplier" do
      random_product = create(:product, :sellable)
      create(:order_item, order: order, product: random_product)
      order.reload
      credit.reload
      credit.amount = order.total_cost
      expect(order).to be_valid
      credit.payer_type = Credit::ORGANIZATION
      expect(order).to be_valid
      credit.paying_org = order.sellers.first
      expect(credit).to_not be_valid
    end

    it "cannot be negative" do
      credit.amount = -1
      expect(credit).to_not be_valid
      expect(credit).to have(1).error_on(:amount)
    end

    it "is automatically rounded to 2 decimal places" do
      credit.amount = 2.345
      credit.save
      expect(credit.amount).to eql 2.35
    end
  end

  describe ".calculated_amount" do
    it "works" do
      expect(order.gross_total).to eql 6.99
      expect(credit.calculated_amount).to eql 1
      credit.amount_type = Credit::PERCENTAGE
      credit.apply_to = Credit::TOTAL
      credit.amount = 25
      expect(credit.calculated_amount).to eql 1.75
      credit.amount = 75
      expect(credit.calculated_amount).to eql 5.24
    end
  end
end
