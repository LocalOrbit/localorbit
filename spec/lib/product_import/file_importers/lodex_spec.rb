require 'spec_helper'

describe ProductImport::FileImporters::Lodex do

  describe "extract stage" do
    subject { described_class.new.stage_named(:extract) }

    it "turns a table into hashes" do
      data = [
        ["product_code", "name", "category", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]
      success, fail = subject.transform.transform_enum(data)

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

    it "rejects if required fields are missing" do
      data = [
        ["product_code", "name", "category", "price", "unit"],
        ["abc123", "St. John's Wart", "Herbs", "1.23", "lbs"],
      ]

      data.first.each.with_index do |k, i|
        bad_data = data.deep_dup
        bad_data.first[i] = 'wrong'

        success, fail = subject.transform.transform_enum(bad_data)
        expect(success.length).to eq(0)
        expect(fail.length).to eq(2)
      end

    end
  end


  describe "the extract and canonicalize stages" do
    subject {
      importer = described_class.new
      importer.transform_for_stages(:extract..:canonicalize)
    }

    it "produces data in the canonical format" do
      data = [
        ["product_code", "organization","name", "category", "price", 'unit', 'unit_description'],
        ["abc123", "orgname","St. John's Wart", "Herbs", "1.23", 'Each','1/72 oz'],
        [" ", "orgname","St. John's Wort", "Herbs", "1.23", 'Each','1/72 oz'], # product code blank OK: name must be different because otherwise same fields in same list, won't be written
        # Rejects blanks appropriately
        ["abc123","  ", "St. John's Wart", "Herbs", "1.23", 'Each','1/72 oz'], 
        ["abc123", "orgname","               ", "Herbs", "1.23", 'Each','1/72 oz'],
        ["abc123", "orgname","St. John's Wart", "     ", "1.23", 'Each','1/72 oz'],
        ["abc123", "orgname","St. John's Wart", "Herbs", "    ", 'Each','1/72 oz'],
        ["abc123", "orgname","St. John's Wart", "Herbs", "1.23", '          ','1/72 oz'],
        ["abc123", "orgname","St. John's Wart", "Herbs", "1.23", 'Each',''],

        # Catches invalid price
        ["abc123", "St. John's Wart", "Herbs", "dolla", '2/3 lb tub'],
      ]

      success, fail = subject.transform_enum(data)
      binding.pry
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)
      expect(success.length).to eq(2)
      expect(fail.length).to eq(data.length - success.length - 1)
    end
  end

  describe "File read test" do
    it "parses and canonicalizes a csv" do
      file = test_file("lodex_good_and_bad.csv")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)
      expect(success.size).to eq(1)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(fail.size).to eq(5)
    end

    it "bails out on csvs missing required columns" do
      file = test_file("lodex_missing_headers.csv")

      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error(ArgumentError)
    end

    it "bails out if the file is empty" do
      file = test_file("empty")

      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error(ArgumentError)
    end

    it "bails out if the file is not a csv" do
      file = test_file("bakers.xlsx")

      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error(ArgumentError)
    end

    it "stashes extra fields in the source_data field" do
      file = test_file("lodex_with_extra_fields.csv")

      success,failure = subject.run_through_stage(:canonicalize, filename: file)

      expect(success.size).to eq(2)

      expect(success[0]["source_data"]).to eq({
        "catalog_id" => "32",
        "smell" => "strong",
      })

      expect(success[1]["source_data"]).to eq({
        "catalog_id" => "32",
        "smell" => nil,
      })
    end
  end

  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
