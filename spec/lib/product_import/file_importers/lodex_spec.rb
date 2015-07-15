require 'spec_helper'

describe ProductImport::FileImporters::Lodex do

  describe "extract stage" do
    subject { described_class.new.stage_named(:extract).transform }
  
    it "does something" do
      data = [
        ["product_code", "name", "category", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)

      expect(success).to eq([
        {
          "product_code" => "abc123",
          "name" => "St. John's Wart",
          "category" => "Herbs", 
          "price" => "1.23",
          "unit" => "lbs",
        },
      ])
      expect(fail.length).to eq(0)
    end

    it "rejects if product_code is missing" do
      data = [
        ["produkt_kode", "name", "category", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if name is missing" do
      data = [
        ["product_code", "namez", "category", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if category is missing" do
      data = [
        ["product_code", "name", "categoryz", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if price is missing" do
      data = [
        ["product_code", "name", "category", "pricez", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if unit is missing" do
      data = [
        ["product_code", "name", "category", "price", "unitz"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end
  end


  describe "all converstions and validations" do
    subject { 
      importer = described_class.new(
        market_id: 123,
        organization_id: 234
      )
      importer.transform_for_stages(:extract, :canonicalize) 
    }

    it "converts to the canonical format" do
      data = [
        ["product_code", "name", "category", "price", 'unit'],
        ["abc123", "St. John's Wart", "Herbs", "1.23", '2/3 lb tub'],
      ]

      success, fail = subject.transform_enum(data)

      expect(success).to be_canonical_product_data
      expect(fail.length).to eq(0)
    end
  end

end
