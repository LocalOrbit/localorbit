require 'spec_helper'

describe ProductImport::Formats::Xlsx do
  it "should be able to read a xls file" do
    file = test_file("cooks.xlsx")
    enum = subject.enum_for(filename: file)

    # NOTE: The xlsx library is automatically converting some values based on their type. The following do not exactly match the values shown in
    # Excel
    expect(enum.take(3)).to eq([
      ["item", "desc", "master", "split", "priccode", "group", "gname", "spluom", "mstruom", "packsize", "organic", "brandcode", "brandname",],
      ["LARUB", "Arugala-Bunched", 10.85, 1.1, "2", "102", "ARUGALA", "BNCH", "DOZN", "12/0", 0, "", "",],
      ["LARO", "Organic Arugala", 17.65, 0, "2", "102", "ARUGALA", "", "CASE", "0/4", 1, "HEIRL", "HEIRLOOM ORGANIC GARDENS",],
    ])
  end

  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
