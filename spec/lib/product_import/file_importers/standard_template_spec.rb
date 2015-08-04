require 'spec_helper'

describe ProductImport::FileImporters::StandardTemplate do

  describe "extract stage" do
    subject { described_class.new.transform_for_stages(:extract) }

    let(:data) {
      [
        ["Seller Name" , "Product Name"                   , "Category Name" , "Short Description" , "Supplier  Product Number" , "Unit Name" , "Unit Description (optional)" , "Price" , "Customer Category" , "Customer Unit of Measure" , "Customer Original Price" , "Customer Unit of Measure"] , 
        ["Bi-Rite"     , "DON JUAN CAKE FIG WITH ALMONDS" , "Miscellaneous" , "1 / 11# AVG"       , "31604"                    , "Each"      , "1 / 11# AVG"                 , "71.39" , "CONDIMENTS"        , "11# AVG"                  , "6.49"                    , "11# AVG"                   , "FALSE"] , 
      ]
    }

    it "turns a table into hashes" do
      success, fail = subject.transform_enum(data)
      expect(fail).to eq([])

      expect(success).to eq([
        {
          "Seller Name"=>"Bi-Rite",
          "Product Name"=>"DON JUAN CAKE FIG WITH ALMONDS",
          "Category Name"=>"Miscellaneous",
          "Short Description"=>"1 / 11# AVG",
          "Supplier  Product Number"=>"31604",
          "Unit Name"=>"Each",
          "Unit Description (optional)"=>"1 / 11# AVG",
          "Price"=>"71.39",
          "Customer Category"=>"CONDIMENTS",
          "Customer Unit of Measure"=>"11# AVG",
          "Customer Original Price"=>"6.49",
          12=>"FALSE"
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
    it "parses and canonicalizes a standard_template file" do
      file = test_file("Bi-Rite Zynga Supplier Product Listing Import Template.xlsx")

      puts "Loading #{file}"
      success, fail = subject.run_through_stage(:canonicalize, filename: file)

      expect(fail.first).to eq(nil)
      expect(success.size).to eq(8438)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(success[0]).to eq({
        "category" => "Breads & Baked Goods",
        "name" => "SARA LEE BAGEL PLAIN PRESLICED",
        "price" => 24.03,
        "product_code" => 10300,
        "source_data" => {
          "Seller Name"=>"Bi-Rite",
          "Product Name"=>"SARA LEE BAGEL PLAIN PRESLICED",
          "Category Name"=>"Miscellaneous",
          "Short Description"=>"72 / 3 OZ",
          "Supplier Product Number"=>10300,
          "Unit Name"=>"Each",
          "Unit Description (optional)"=>"72 / 3 OZ",
          "Price"=>24.03,
          "Customer Category"=>"BAKED GOODS",
          "Customer Unit of Measure"=>"3 OZ",
          "Customer Original Price"=>24.03,
          12=>1},

        "unit" => "72 / 3 OZ",
        "uom" => "Each",
      })
    end

  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
