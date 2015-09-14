require 'spec_helper'

describe ProductImport::Formats::Csv do
  it "should be able to read a csv file" do
    file = test_file("lodex_good_and_bad.csv")
    enum = subject.enum_for(filename: file)

    expect(enum.take(2)).to eq([
      ["product_code", "organization","name", "category", "price", 'unit', 'unit_description'],
      ["abc123", "bi-rite", "St. John's Wart", "Herbs", "1.23", 'Each', '2/3 lb tub'],
    ])
  end

  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
