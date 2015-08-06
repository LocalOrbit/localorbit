require 'spec_helper'

describe ProductImport::Formats::Xls do
  it "should be able to read a xls file" do
    file = test_file("barons_specialty_foods.xls")
    enum = subject.enum_for(filename: file)

    # The barons file is wretched.
    expect(enum.take(5)).to eq([
      [nil                                      , nil , nil , nil , nil , nil , nil] , 
      ["Zynga Master Order Guide"               , nil , nil , nil , nil , nil , nil] , 
      [nil                                      , nil , nil , nil , nil , nil , nil] , 
      ["Ordering:"                              , nil , nil , nil , nil , nil , nil] , 
      ["Email: orders@baronsspecialtyfoods.com" , nil , nil , nil , nil , nil , nil]
    ])
  end

  def test_file(fname)
    path = Rails.root + "spec/lib/product_import/test_data" + fname
    raise ArgumentError, "Unknown test file #{fname}" unless path.file?
    path
  end
end
