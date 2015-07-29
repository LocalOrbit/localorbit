require 'spec_helper'

describe ProductImport::FileImporters::BakersOfParis do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        [nil , nil      , nil                     , nil             , nil]            , 
        [nil , nil      , nil                     , nil             , nil]            , 
        [nil , nil      , "FRENCH BREAD"          , nil             , "As Of 8/1/14"] , 
        [nil , "CODE"   , "PRODUCTS"              , "Reorder Cycle" , nil             , "PRICE"] , 
        [nil , "A30050" , "Baguette Long"         , nil             , "24hr"          , 1.24     , nil] , 
        [nil , "A80050" , "Baguette Short"        , nil             , "24hr"          , 1.24     , nil] , 
        [nil , "A10050" , "Batard"                , nil             , "24hr"          , 1.24     , nil] , 
        [nil , "A50050" , "Boule"                 , nil             , "24hr"          , 2.1      , nil] , 
        [nil , "A20050" , "Pain Long"             , nil             , "24hr"          , 1.63     , nil] , 
        [nil , "A20053" , "Pain Long  Light bake" , nil             , "24hr"          , 1.63     , nil] , 
        [nil , "A60050" , "Pain Rustic"           , nil             , "24hr"          , 1.63     , nil] , 
        [nil , "A40050" , "Petite Baguette"       , nil             , "24hr"          , 0.67     , nil] , 
        [nil , nil      , nil                     , nil             , nil             , nil]     , 
        [nil , nil      , "SOUR BREAD"            , nil             , nil             , nil]     , 
        [nil , "CODE"   , "PRODUCTS"              , "Reorder Cycle" , nil             , "PRICE"] , 
        [nil , "A10015" , "Sour Batard"           , nil             , "48hr"          , 2.65     , nil] , 
        [nil , "S20051" , "Sour Baguette"         , nil             , "48hr"          , 1.35     , nil] , 
        [nil , nil      , nil                     , nil             , nil             , nil]     , 
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])

      expect(success[0]).to eq(
        {
          "CODE" => "A30050",
          "PRODUCTS" => "Baguette Long",
          "Reorder Cycle" => nil,
          nil => "24hr",
          "PRICE" => 1.24,
          # 6 => nil,
          "category" => "FRENCH BREAD",
        }
      )

      expect(success[8]).to eq(
        {
          "CODE" => "A10015",
          "PRODUCTS" => "Sour Batard",
          "Reorder Cycle" => nil,
          nil => "48hr",
          "PRICE" => 2.65,
          # 6 => nil,
          "category" => "SOUR BREAD",
        }
      )

      expect(success.length).to eq(10)
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
    it "parses and canonicalizes a bakers_of_paris file" do
      pending

      file = test_file("bakers_of_paris.xlsx")

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
