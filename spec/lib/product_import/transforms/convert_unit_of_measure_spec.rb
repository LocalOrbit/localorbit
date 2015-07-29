require 'spec_helper'

describe ProductImport::Transforms::ConvertUnitOfMeasure do

  def test_uom(price:, uom:, package:, expect_price:, **rest)
    expect_lbs = rest[:expect_lbs]
    expect_qty = rest[:expect_qty]

    data = [
      {"uom" => uom, "package" => package, "price" => price},
    ]

    successes, failures = subject.transform_enum(data)

    expect(failures).to eq([])

    expect(successes.size).to eq(1)
    value = successes[0]

    expect(value["uom"]).to eq(uom)
    expect(value["package"]).to eq(package)

    if expect_qty
      expect(value['qty_per_case']).to eq(expect_qty)
    end

    if expect_lbs
      expect(value['lbs_per_item']).to be_within(0.01).of(expect_lbs)
    end

    expect(value["original_price"]).to eq(price) # 6 * 6 * 1.03
    expect(value["price"]).to eq(expect_price)# 6 * 6 * 1.03

  end

  describe "when UOM is 'case'" do
    it "handles various formats" do
      test_uom(price:"1.03", uom: "case", package: "6/6 LB LOAVES", 
          expect_price: '1.03')
    end

  end

  describe "when UOM is 'piece'" do
    it "handles various formats" do
      test_uom(price:"1.03", uom: "piece", package: "6/6 LB LOAVES", 
          expect_qty: 6, expect_price: '6.18')

      test_uom(price:"1.03", uom: "piece", package: "3# AVG",
          expect_qty: 1, expect_price: '1.03')

      test_uom(price:"1.03", uom: "piece", package: "1/9 LBS",
          expect_qty: 1, expect_price: '1.03')

      test_uom(price:"1.03", uom: "piece", package: "lb",
          expect_qty: 1, expect_price: '1.03')

      test_uom(price:"1.03", uom: "piece", package: "lb",
          expect_qty: 1, expect_price: '1.03')

    end

  end

  describe "When UOM is 'pound'" do
    it "handles various formats" do
      test_uom(price:"1.03", uom: "pound", package: "6/6 LB LOAVES", 
          expect_qty: 6, expect_lbs: 6.0, expect_price: '37.08')

      test_uom(price:"1.03", uom: "pound", package: "3# AVG",
          expect_qty: 1, expect_lbs: 3.0, expect_price: '3.09')

      test_uom(price:"1.03", uom: "pound", package: "1/9 LBS",
          expect_qty: 1, expect_lbs: 9.0, expect_price: '9.27')

      test_uom(price:"1.03", uom: "pound", package: "lb",
          expect_qty: 1, expect_lbs: 1, expect_price: '1.03')

      test_uom(price:"1.03", uom: "pound", package: "lb",
          expect_qty: 1, expect_lbs: 1, expect_price: '1.03')

      test_uom(price:"1.03", uom: "pound", package: "5 LB BLOCK 2 /",
          expect_qty: 2, expect_lbs: 5.0, expect_price: '10.30')

    end

    it "supports kgs" do

      test_uom(price:"1.03", uom: "pound", package: "6/3 KG BC",
          expect_qty: 6, expect_lbs: 6.6, expect_price: '40.79')

    end

    it "supports oz" do
      test_uom(price:"1.03", uom: "pound", package: "6/3 OZ BC",
          expect_qty: 6, expect_lbs: 0.1875, expect_price: '1.16')
    end
  end

end
