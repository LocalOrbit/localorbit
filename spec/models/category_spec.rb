require "spec_helper"

describe Category do
  describe "#for_select" do
    subject { Category.for_select }
    it "returns a list of categories for select options" do
      expect(subject.count).to eql(3)
    end

    it "categories should include parent info" do
      id = Category.find_by!(name: "Bananas").id
      expect(subject["Fruits"]).to include(["Bananas", id])

      id = Category.find_by!(name: "Macintosh Apples").id
      expect(subject["Fruits"]).to include(["Apples / Macintosh Apples", id])
    end

    it "includes the root categories" do
      expect(subject).to include("Fruits")
    end

    it "returns keys in sorted order" do
      expect(subject.keys).to eq(["Fruits", "Vegetables", "Beverages"])
    end
  end
end
