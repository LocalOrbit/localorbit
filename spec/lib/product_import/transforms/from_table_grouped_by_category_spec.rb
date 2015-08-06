require 'spec_helper'

describe ProductImport::Transforms::FromTableGroupedByCategory do
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

  subject {
    described_class.new(
      category_column: 2,
      header_row_pattern: [nil, "CODE", "PRODUCTS", nil, nil, "PRICE"],
      required_headers: %w(CODE PRODUCTS PRICE)
    )
  }

  it "turns a table into hashes and inserts the category" do
    success, fail = subject.transform_enum(data)
    expect(fail).to eq([])

    expect(success[0]).to eq(
      {
        "CODE" => "A30050",
        "PRODUCTS" => "Baguette Long",
        "Reorder Cycle" => nil,
        nil => "24hr",
        "PRICE" => 1.24,
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
        "category" => "SOUR BREAD",
      }
    )

    expect(success.length).to eq(10)
  end

end
