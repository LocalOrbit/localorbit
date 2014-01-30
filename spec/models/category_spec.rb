require 'spec_helper'

describe Category do
  describe "#for_select" do
    subject { Category.for_select }
    it "returns a list of categories for select options" do
      expect(subject.count).to eql(69)
    end

    it "categories should include parent info" do
      id = Category.where(name: 'Apples').first.id
      expect(subject).to include(["Fruits > Apples", id])

      id = Category.where(name: 'Macintosh Apples').first.id
      expect(subject).to include(["Fruits > Apples > Macintosh Apples", id])
    end

    it "includes the root categories" do
      id = Category.where(name: 'Fruits').first.id
      expect(subject).to include(["Fruits", id])
    end
  end
end
