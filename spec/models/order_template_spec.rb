require "spec_helper"

describe OrderTemplate do
  it "requires a name and a market" do
    template = OrderTemplate.new
    expect(template).to_not be_valid
    expect(template).to have(1).error_on(:name)
    expect(template).to have(1).error_on(:market)
  end

  it "cannot have duplicate names within the same market" do
    market1 = create(:market)
    market2 = create(:market)
    original_template = OrderTemplate.create(market: market1, name: "dup")
    template2 = OrderTemplate.new(market: market1, name: "dup")
    expect(template2).to_not be_valid
    template3 = OrderTemplate.new(market: market2, name: "dup")
    expect(template3).to be_valid
  end

  describe "create_from_cart" do
    let(:cart) { create(:cart) }
    let!(:cart_item1) { create(:cart_item, cart: cart, quantity: 1) }
    let!(:cart_item2) { create(:cart_item, cart: cart, quantity: 2) }

    it "creates and persists a new order template from a cart, given a name" do
      name = "Template #{Time.now}"
      template = OrderTemplate.create_from_cart!(cart, name)
      template_items = template.items.sort { |a,b| a.quantity <=> b.quantity }

      expect(template.name).to eq name
      expect(template_items.length).to eq 2

      item1 = template_items.first
      item2 = template_items.second

      expect(item1.product).to eq cart_item1.product
      expect(item1.quantity).to eq 1
      expect(item2.product).to eq cart_item2.product
      expect(item2.quantity).to eq 2

      expect(OrderTemplate.all.count).to eq 1
      expect(OrderTemplateItem.all.count).to eq 2
    end
  end
end
