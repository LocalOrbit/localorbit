require 'spec_helper'

describe ProductImport::FileImporters::BaronsSpecialtyFoods do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        [nil, nil, nil, nil, nil, nil, nil],
        ["Zynga Master Order Guide", nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        ["Ordering:", nil, nil, nil, nil, nil, nil],
        ["Email: orders@baronsspecialtyfoods.com", nil, nil, nil, nil, nil, nil],
        ["Fax:  Fax order form to (925)-370-1523", nil, nil, nil, nil, nil, nil],
        ["Shipping: Ships within 24hrs of reciept. Allow 1-5 days for UPS Ground Transit.", nil, nil, nil, nil, nil, nil],
        ["Minimum order 12#", nil, nil, nil, nil, nil, nil],
        ["Store: ", nil, nil, nil, "Date:", nil, nil],
        ["Street Address:", nil, nil, nil, nil, nil, nil],
        ["City:", "State:", nil, nil, "Zip:", nil, nil],
        ["Ordered By: ", nil, nil, nil, nil, nil, nil],
        ["P.O number:", nil, nil, nil, "Rush", nil, nil],
        ["Sausage Seasonings, Seasonings, Marinades & Herbs", nil, nil, nil, nil, nil, nil],
        ["Item", "Item #", "Package Size", "Price/#", "Price/cs.", "QTY.", "Container"],
        ["Banger", "11025-142-10", "4#/bag", 7.34, 29.36, nil, nil],
        ["Beef Stick ", "11042-140-10", "3x4#=12#/cs.", 4.49, 53.88, nil, nil],
        ["Greek Feta & Whiskey Fennel Seasoning", "11190-142-10", "4#/bag", 5.72, 22.89, nil, nil],
        ["Hickory Smoked Salt & Pepper", "H11540-405", "7# Lrg Container", 6.79, 47.53, nil, nil],
        ["Hot Dog Seasoning", "11220-104-10", "5x2.71#=13.55#", 5.99, 81.16, nil, nil],
        ["Hot Habanero & Green Chili Seasoning", "11225-142-10", "4#/bag", 7.86, 31.46, nil, nil],
        [" ", "11225-405-10", "7# Lrg Container", 8.19, 57.34, nil, nil],
        ["Pepperoni (Reduced Salt)", "11341-142-10", "4#/bag", 5.96, 23.84, nil, nil],
        ["\"Organic\" Santa Maria Style Ranch", "30407-405-10", "8# Lrg Container", 4.69, 37.52, nil, nil],
        ["Southwest Texas BBQ w/Chipotle", "11430-142-10", "4#/bag", 5.24, 20.96, nil, nil],
        ["Soy Garlic & Mesquite", "11435-116-10", "5x3.08#=15.40#", 5.99, 92.25, nil, nil],
        ["Soy Garlic & Mesquite", "11435-142-10", "3.08#/bag", 6.29, 19.37, nil, nil],
        ["Thai Curry", "11468-142-10", "4#/bag", 6.08, 24.32, nil, nil],
        ["Seasoning Packets (Each Unit for 10.00#'s of Meat)", nil, nil, nil, nil, nil, nil],
        ["Item", "Item #", "Package Size", "Price/Unit", "Price/cs.", "QTY.", "Container"],
        ["Bratwurst Sausage Seasoning  (CT, P, & B)", "11070-182-52", "20 units/cs", 1.89, 37.8, nil, nil],
        ["Country Breakfast w/ Maple Sausage Seasoning (CT & P)", "11160-182-52", "20 units/cs", 2.29, 45.8, nil, nil],
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])
      expect(success.length).to eq(15)

      expect(success[0]).to eq({
        "Item"=>"Banger",
        "Item #"=>"11025-142-10",
        "Package Size"=>"4#/bag",

        "Price/#"=>7.34,
        "Price/cs."=>29.36,
        "QTY."=>nil,
        "Container"=>nil,
        "category"=>"Sausage Seasonings, Seasonings, Marinades & Herbs"
      })
    end

  end




  describe "Processing a file" do
    it "parses and canonicalizes a barons_specialty_foods file" do
      file = test_file("barons_specialty_foods.xls")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)
      expect(fail).to eq([])

      expect(success.size).to eq(1)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

    end

    it "stashes extra fields in the source_data field" do
      pending
      file = test_file("lodex_with_extra_fields.csv")

      success,failure = subject.run_through_stage(:canonicalize, filename: file)

      expect(success.size).to eq(2)

      expect(success[0]["source_data"]).to eq({
        # ...
      })
    end
  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
