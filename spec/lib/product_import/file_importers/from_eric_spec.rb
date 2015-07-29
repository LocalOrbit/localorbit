require 'spec_helper'

describe ProductImport::FileImporters::FromEric do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        ["Seller Name", "Product Name", "Category Name", "Category ID", "Photo (url)", "Short Description", "Long Description", "Supplier Product Number", "Unit Name", "Unit ID", "Unit Description (optional)", "Price", "", "Customer Category", "Customer Unit"],
        ["The Chef's Warehouse", "AGRIMONTANA CANDIED LEMON", "Baking Mixes", "", "", "2/2.5 KG", "", "GB880", "Cases", "9", "", "222.65", "", "Baking products - DÃ‰COR", "CS"],
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])

      expect(success).to eq([
        {
          "Seller Name"=>"The Chef's Warehouse",
          "Product Name"=>"AGRIMONTANA CANDIED LEMON",
          "Category Name"=>"Baking Mixes",
          "Category ID"=>"",
          "Photo (url)"=>"",
          "Short Description"=>"2/2.5 KG",
          "Long Description"=>"",
          "Supplier Product Number"=>"GB880",
          "Unit Name"=>"Cases",
          "Unit ID"=>"9",
          "Unit Description (optional)"=>"",
          "Price"=>"222.65",
          "Customer Category"=>"Baking products - DÃ‰COR",
          "Customer Unit"=>"CS",
          12=>""
        }
      ])
    end

    described_class::REQUIRED_HEADERS.each do |required_key|
      it "rejects if required field #{required_key} is missing" do
        idx = data[0].index(required_key)
        bad_data = data.deep_dup
        bad_data.first[idx] = 'wrong'

        success, fail = subject.transform_enum(bad_data)
        expect(success.length).to eq(0)
        expect(fail.length).to eq(2)
      end
    end
  end


  describe "Processing a file" do
    it "parses and canonicalizes a from_eric file" do
      file = test_file("chefs_warehouse_from_eric.csv")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)
      expect(success.size).to eq(80)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)
      expect(fail).to eq([])

      expect(success[0]).to eq({
        "category" => "Baking Mixes",
        "name" => "AGRIMONTANA CANDIED LEMON",
        "price" => "222.65",
        "product_code" => "GB880",
        "unit" => "2/2.5 KG",
        "source_data" => {
          "Seller Name"=>"The Chef's Warehouse",
          "Product Name"=>"AGRIMONTANA CANDIED LEMON",
          "Category Name"=>"Baking Mixes",
          "Category ID"=>nil,
          "Photo (url)"=>nil,
          "Short Description"=>"2/2.5 KG",
          "Long Description"=>nil,
          "Supplier Product Number"=>"GB880",
          "Unit Name"=>"Cases",
          "Unit ID"=>"9",
          "Unit Description (optional)"=>nil,
          "Price"=>"222.65",
          "Customer Category"=>"Baking products - DÉCOR",
          "Customer Unit"=>"CS",
          12=>nil
        },
      })
    end

  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
