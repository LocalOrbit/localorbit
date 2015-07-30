require 'spec_helper'

describe ProductImport::FileImporters::ChefsWarehouse do






  describe "Processing a file" do
    it "parses and canonicalizes a chefs_warehouse file" do
      file = test_file("chefs_warehouse.xlsx")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)

      expect(fail).to eq([])
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(success[0]).to eq({
        "category" => "Baking Mixes",
        "name" => "AGRIMONTANA CANDIED LEMON",
        "price" => "222.65",
        "product_code" => "GB880",
        "source_data" => {"CLASS -SUBCLASS"=>"Baking products - DÉCOR", "ITEM"=>"GB880", "DESCRIPTION"=>"AGRIMONTANA CANDIED LEMON", "PACK"=>"2/2.5 KG", "UOM"=>"CS", "LASTPURCHASED"=>20141211, "LASTPRICE"=>222.65, "uom"=>"CS", "original_price"=>222.65},
        "unit" => "2/2.5 KG",
      })

    end


  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
