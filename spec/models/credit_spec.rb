require "spec_helper"

describe Credit do
  it "requires an order, user, type, and amount" do
    credit = create(:credit)
    expect(credit).to be_valid
    credit.order = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:order)
    credit.reload
    credit.user = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:user)
    credit.reload
    credit.percentage_or_fixed = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:percentage_or_fixed)
    credit.reload
    credit.amount = nil
    expect(credit).to_not be_valid
    expect(credit).to have(1).error_on(:amount)
    credit.reload
  end

  it "only allows two possible types in 'percentage_or_fixed'" do
    credit = create(:credit)
    expect(credit).to be_valid
    credit.percentage_or_fixed = "cat"
    expect(credit).to_not be_valid
    credit.reload
    credit.percentage_or_fixed = Credit::PERCENTAGE
    expect(credit).to be_valid
    credit.reload
    credit.percentage_or_fixed = Credit::FIXED
    expect(credit).to be_valid
  end
end
