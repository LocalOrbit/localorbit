require 'spec_helper'

describe 'Adding advanced pricing' do
  let(:user)    { create(:user) }
  let(:market)  { create(:market) }
  let!(:organization) { create(:organization, markets: [market]) }
  let!(:product) do
    create(:product).tap do |p|
      p.organization.users << user
      market.organizations << p.organization
    end
  end

  before do
    sign_in_as(user)
    click_link 'Products'
    click_link product.name
    click_link 'Pricing'
  end

  it 'completes successfully given valid information' do
    fill_in 'price_sale_price', with: '1.90'
    click_button 'Add'

    record = Dom::PricingRow.first
    expect(record.market).to eq('All Markets')
    expect(record.buyer).to eq('All Buyers')
    expect(record.min_quantity).to eq('1')
    expect(record.net_price).to eq('$1.84')
    expect(record.sale_price).to eq('$1.90')
  end

  describe "invalid input" do
    it "shows error messages" do
      fill_in 'price_sale_price', with: '0'
      fill_in 'price_min_quantity', with: '0'
      click_button 'Add'

      expect(page).to have_content("Sale price must be greater than 0")
      expect(page).to have_content("Min quantity must be greater than 0")
    end
  end

  describe "entering duplicate pricing" do
    it "shows an error" do
      fill_in 'price_min_quantity', with: '2'
      fill_in 'price_sale_price', with: '1.99'
      click_button 'Add'

      fill_in 'price_min_quantity', with: '2'
      fill_in 'price_sale_price', with: '1.50'
      click_button 'Add'

      expect(page).to have_content("Min quantity must be unique")
    end

    it "allowed for different buyers" do
      fill_in 'price_min_quantity', with: '2'
      fill_in 'price_sale_price', with: '1.99'
      click_button 'Add'

      select organization.name, from: 'price_organization_id'
      fill_in 'price_min_quantity', with: '2'
      fill_in 'price_sale_price', with: '1.50'
      click_button 'Add'

      expect(page).to_not have_content("Min quantity must be unique")
      expect(page).to have_content("Successfully added a new price")
    end
  end

  describe "pricing for a specific buyer" do
    it "saves the buyer" do
      fill_in 'price_sale_price', with: '1.99'
      select organization.name, from: 'price_organization_id'
      click_button 'Add'

      record = Dom::PricingRow.first
      expect(record.market).to eq('All Markets')
      expect(record.buyer).to eq(organization.name)
      expect(record.min_quantity).to eq('1')
      expect(record.net_price).to eq('$1.93')
      expect(record.sale_price).to eq('$1.99')
    end
  end
end
