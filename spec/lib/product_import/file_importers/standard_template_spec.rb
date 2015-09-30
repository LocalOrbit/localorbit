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

      # Removed specific case -- bad test as format changes. Specific formats are tested in other specs.
    end

  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
