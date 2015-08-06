require 'spec_helper'

describe ProductImport::FileImporters::StandardTemplate do

  describe "Processing a file" do
    it "parses and canonicalizes a standard_template file" do
      file = test_file("Bi-Rite Zynga Supplier Product Listing Import Template.xlsx")

      puts "Loading #{file}"
      success, fail = subject.run_through_stage(:canonicalize, filename: file)

      expect(fail.first).to eq(nil)
      expect(success.size).to eq(100)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(success[0]).to eq({
        "category" => "Breads & Baked Goods",
        "name" => "SARA LEE BAGEL PLAIN PRESLICED",
        "price" => 24.03,
        "product_code" => 10300,
        "organization" => "Bi-Rite",
        "contrived_key" => ExternalProduct.contrive_key(['10300']),
        "source_data" => {
          "Seller Name"=>"Bi-Rite",
          "Product Name"=>"SARA LEE BAGEL PLAIN PRESLICED",
          "Category Name"=>"Breads & Baked Goods",
          "Short Description"=>"72 / 3 OZ",
          "Supplier Product Number"=>10300,
          "Unit Name"=>"Each",
          "Unit Description (optional)"=>"72 / 3 OZ",
          "Price"=>24.03,
          "Customer Category"=>"BAKED GOODS",
          "Customer Unit of Measure"=>"3 OZ",
          "Customer Original Price"=>24.03,
          12=>1},

        "unit_description" => "72 / 3 OZ",
        "unit" => "Each",
      })
    end

  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
