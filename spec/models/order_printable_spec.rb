require 'spec_helper'

describe OrderPrintable, :type => :model, wip:true do
  subject { create(:order_printable) }

  it "can be created" do 
    expect(subject).to be
    expect(subject.include_product_names).to eq false
    expect(subject.printable_type).to eq "table tent"
    expect(subject.user).to be
    expect(subject.order).to be
  end

  it "belongs to a User" do
    expect(subject.user).to be_a(User)
  end

  it "belongs to an Order" do
    expect(subject.order).to be_a(Order)
  end

  it "has a PDF attachment" do
    subject.pdf = "fake data"
    expect(subject.pdf.file.read).to eq("fake data")
    subject.pdf = nil
    subject.save
  end
  
  describe ".for_user scope" do
    let!(:user) { create(:user) }
    let!(:admin) { create(:user, :admin) }
    let!(:order_printables) { create_list(:order_printable, 2, user: user) }
    let!(:other_order_printables) { create_list(:order_printable, 2, user: create(:user)) }

    it "returns scoped OrderPrintables for the User" do
      expect(OrderPrintable.for_user(user)).to contain_exactly(*order_printables)
    end

    it "returns all OrderPrintables for an admin" do
      expect(OrderPrintable.for_user(admin)).to contain_exactly(*OrderPrintable.all.to_a)
    end
  end
end
