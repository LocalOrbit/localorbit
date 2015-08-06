require 'spec_helper'

describe ProductImport::FileImporters::Birite do



  describe "Processing a file" do
    it "parses and canonicalizes a birite file" do
      file = test_file("birite_utf8.CSV")

      success, fail = subject.run_through_stage(:canonicalize, filename: file)
      expect(success.size).to eq(8438)
      expect(success).to be_array_compliant_with_schema(ProductImport::Schemas::CANONICAL)

      expect(fail.size).to eq(1)
    end

  end


  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
