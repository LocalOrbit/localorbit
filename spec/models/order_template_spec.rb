require "spec_helper"

describe OrderTemplate do
  it "requires a name and a market" do
    template = OrderTemplate.new
    expect(template).to_not be_valid
    expect(template).to have(1).error_on(:name)
    expect(template).to have(1).error_on(:market)
  end

  describe "create_from_cart" do
    let(:cart) { create(:cart) }
    let!(:cart_item1) { create(:cart_item, cart: cart, quantity: 1) }
    let!(:cart_item2) { create(:cart_item, cart: cart, quantity: 2) }

    it "creates and persists a new order template from a cart, given a name" do
      name = "Template #{Time.now}"
      template = OrderTemplate.create_from_cart!(cart, name)
      expect(template.name).to eq name
      expect(template.items.length).to eq 2

      item1 = template.items.first
      item2 = template.items.second

      expect(item1.product).to eq cart_item1.product
      expect(item1.quantity).to eq 1
      expect(item2.product).to eq cart_item2.product
      expect(item2.quantity).to eq 2

      expect(OrderTemplate.all.count).to eq 1
      expect(OrderTemplateItem.all.count).to eq 2
    end
  end

  describe "convert_to_cart", :wip do
    let(:order_template) { create(:order_template) }
    let!(:order_template_item1) { create(:order_template_item, order_template: order_template, quantity: 1) }
    let!(:order_template_item2) { create(:order_template_item, order_template: order_template, quantity: 2) }
  end

  it "creates and persists a new order template from a cart, given a name" do
    name = "Template #{Time.now}"
    template = OrderTemplate.create_from_cart!(cart, name)
    expect(template.name).to eq name
    expect(template.items.length).to eq 2

    item1 = template.items.first
    item2 = template.items.second

    expect(item1.product).to eq cart_item1.product
    expect(item1.quantity).to eq 1
    expect(item2.product).to eq cart_item2.product
    expect(item2.quantity).to eq 2

    expect(OrderTemplate.all.count).to eq 1
    expect(OrderTemplateItem.all.count).to eq 2
  end
end
