require "spec_helper"

describe OrderTemplateItem do
  it "requires a template, product, and quantity" do
    item = OrderTemplateItem.new
    expect(item).to_not be_valid
    expect(item).to have(1).error_on(:order_template)
    expect(item).to have(1).error_on(:product)
    expect(item).to have(1).error_on(:quantity)
  end
end
