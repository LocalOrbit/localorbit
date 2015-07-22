require 'spec_helper'

describe ProductImport::FileImporters::Cooks do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        ["item", "desc", "master", "split", "priccode", "group", "gname", "spluom", "mstruom", "packsize", "organic", "brandcode", "brandname"],
        ["LARUB", "Arugala-Bunched", "10.85", "1.1", "2", "102", "ARUGALA", "BNCH", "DOZN", "12/0", "FALSE", "HEIRL", "HEIRLOOM ORGANIC GARDENS"]
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])

      expect(success).to eq([
        {
          "item" => "LARUB",
          "desc" => "Arugala-Bunched",
          "master" => "10.85",
          "split" => "1.1",
          "priccode" => "2",
          "group" => "102",
          "gname" => "ARUGALA",
          "spluom" => "BNCH",
          "mstruom" => "DOZN",
          "packsize" => "12/0",
          "organic" => "FALSE",
          "brandcode" => "HEIRL",
          "brandname" => "HEIRLOOM ORGANIC GARDENS",
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
        expect(fail.length).to eq(2)
      end
    end
  end


  describe "the canonicalize stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    it "produces data in the canonical format" do
      pending

      data = [
        {
          'product_code' => 'abc123',
          'name' => 'Tomatoes',
        }
      ]

      success, fail = subject.transform_enum(data)

      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)
      expect(success.length).to eq(1)
      expect(fail.length).to eq(data.length - success.length - 1)
    end
  end




  describe "Processing a file" do
    it "parses and canonicalizes a cooks file" do
      pending

      file = test_file("cooks.xlsx")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)
      expect(success.size).to eq(1)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(fail.size).to eq(2)
    end

    it "bails out on spreadsheet missing required columns" do
      pending

      file = test_file("an incomplete file")

      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error(ArgumentError)
    end

    it "bails out if the file is empty" do
      file = test_file("empty")
      expect { subject.run_through_stage(:canonicalize, filename: file) }.to raise_error(ArgumentError)
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
