require "spec_helper"

describe "Viewing products" do
  let(:user) { create(:user) }
  let(:organization_label) { "Product Organization" }
  let(:product) { create(:product) }
  let(:org) { product.organization }

  before do
    org.users << user
    sign_in_as(user)
  end

  it "shows a list of products which the owner manages" do
    click_link "Products"
    expect(page).to have_content(product.name)
  end
end

