require 'spec_helper'

describe ProductImport::FileImporters::PacificGourmet do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        ['SKU', 'DESCRIPTION', 'PACK', 'UOM', 'ITEM CATEGORY', 'BRAND', 'WEIGHT MULTIPLIER', 'AVERAGE WEIGHT', 'PRICED BY WEIGHT?', 'UNIT PRICE'],
        ['ASN01', 'MEI-FUN RICE STICK NOODLES, CHINA', '30/1 lb', 'PC.', 'ASIAN NOODLES', 'SAILING BOAT', '', '', 'N', '1.21']
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])

      expect(success).to eq([
        {
          "SKU"=>"ASN01",
          "DESCRIPTION"=>"MEI-FUN RICE STICK NOODLES, CHINA",
          "PACK"=>"30/1 lb",
          "UOM"=>"PC.",
          "ITEM CATEGORY"=>"ASIAN NOODLES",
          "BRAND"=>"SAILING BOAT",
          "WEIGHT MULTIPLIER"=>"",
          "AVERAGE WEIGHT"=>"",
          "PRICED BY WEIGHT?"=>"N",
          "UNIT PRICE"=>"1.21"
        },
      ])
    end

    described_class::REQUIRED_HEADERS.each do |required_key|
      it "rejects if required field #{required_key} is missing" do
        idx = data[0].index(required_key)
        bad_data = data.deep_dup
        bad_data.first[idx] = 'wrong'

        success, fail = subject.transform_enum(bad_data)
        expect(success.length).to eq(0)
        expect(fail.length).to eq(1)
      end
    end
  end


  describe "the canonicalize stage" do
    subject { described_class.new.transform_for_stages(:canonicalize) }

    it "produces data in the canonical format" do
      data = [
        {
          "SKU"=>"ASN01",
          "DESCRIPTION"=>"MEI-FUN RICE STICK NOODLES, CHINA",
          "PACK"=>"30/1 lb",
          "UOM"=>"PC.",
          "ITEM CATEGORY"=>"ASIAN NOODLES",
          "BRAND"=>"SAILING BOAT",
          "WEIGHT MULTIPLIER"=>"",
          "AVERAGE WEIGHT"=>"",
          "PRICED BY WEIGHT?"=>"N",
          "UNIT PRICE"=>"1.21"
        }
      ]

      success, fail = subject.transform_enum(data)

      expect(fail).to eq([])
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)
      expect(success.length).to eq(1)
    end
  end

  describe "Processing a file" do
    it "parses and canonicalizes a pacific_gourmet file" do
      file = test_file("pacific_gourmet.xlsx")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)

      expect(success.size).to be > 1
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)
      expect(success[0]).to eq({
        "product_code"=>"ASN01",
        "name"=>"SAILING BOAT - MEI-FUN RICE STICK NOODLES, CHINA",
        "category"=>"ASIAN NOODLES",
        "price"=>1.21,
        "unit"=>"30/1 lb",
        "source_data"=>{
          "SKU"=>"ASN01",
          "DESCRIPTION"=>"MEI-FUN RICE STICK NOODLES, CHINA",
          "PACK"=>"30/1 lb",
          "UOM"=>"PC.",
          "ITEM CATEGORY"=>"ASIAN NOODLES",
          "BRAND"=>"SAILING BOAT",
          "WEIGHT MULTIPLIER"=>nil,
          "AVERAGE WEIGHT"=>nil,
          "PRICED BY WEIGHT?"=>"N",
          "UNIT PRICE"=>1.21
        }
      })
      expect(fail).to eq([])
    end

    it "bails out on spreadsheet missing required columns" do
      file = test_file("empty.xlsx")
      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error
    end

    it "bails out if the file is empty" do
      file = test_file("empty")
      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error
    end
  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
