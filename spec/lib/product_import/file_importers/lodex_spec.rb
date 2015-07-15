require 'spec_helper'

describe ProductImport::FileImporters::Lodex do

  describe "extract stage" do
    subject { described_class.new.stage_named(:extract).transform }
  
    it "does something" do
      data = [
        ["product_code", "name", "category", "price"],
        ["abc123", "St. John's Wart", "Herbs", "1.23"],
      ]
      success, fail = subject.transform_enum(data)

      expect(success).to eq([
        {
          "product_code" => "abc123",
          "name" => "St. John's Wart",
          "category" => "Herbs", 
          "price" => "1.23"
        },
      ])
      expect(fail.length).to eq(0)
    end

    it "rejects if product_code is missing" do
      data = [
        ["produkt_kode", "name", "category", "price"],
        ["abc123", "St. John's Wart", "Herbs", "1.23"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if name is missing" do
      data = [
        ["product_code", "namez", "category", "price"],
        ["abc123", "St. John's Wart", "Herbs", "1.23"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if category is missing" do
      data = [
        ["product_code", "name", "categoryz", "price"],
        ["abc123", "St. John's Wart", "Herbs", "1.23"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end

    it "rejects if price is missing" do
      data = [
        ["product_code", "name", "category", "pricez"],
        ["abc123", "St. John's Wart", "Herbs", "1.23"],
      ]
      success, fail = subject.transform_enum(data)
      expect(success.length).to eq(0)
      expect(fail.length).to eq(1)
    end
  end


end
