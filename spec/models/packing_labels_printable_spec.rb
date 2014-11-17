require 'spec_helper'

RSpec.describe PackingLabelsPrintable, :type => :model do
  subject { create(:packing_labels_printable) }

  it "can be created" do
    expect(subject).to be
    expect(subject.user).to be
    expect(subject.delivery).to be
  end

  it "belongs to a User" do
    expect(subject.user).to be_a(User)
  end

  it "belongs to a delivery" do
    expect(subject.delivery).to be_a(Delivery)
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
    let!(:packing_labels_printables) { create_list(:packing_labels_printable, 2, user: user) }
    let!(:other_packing_labels_printables) { create_list(:packing_labels_printable, 2, user: create(:user)) }

    it "returns scoped OrderPrintables for the User" do
      expect(PackingLabelsPrintable.for_user(user)).to contain_exactly(*packing_labels_printables)
    end

    it "returns all OrderPrintables for an admin" do
      expect(PackingLabelsPrintable.for_user(admin)).to contain_exactly(*PackingLabelsPrintable.all.to_a)
    end
  end
end
