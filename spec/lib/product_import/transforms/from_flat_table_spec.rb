require 'spec_helper'

describe ProductImport::Transforms::FromFlatTable do
  it "uses the first row as keys for hashes whose values are subsequent rows" do
    table = [
      ["foo", "bar"],
      [1,2],
      [3,4],
    ]
    success, failure = subject.transform_enum(table)

    expect(success.size).to eq(2)
    expect(success[0]).to eq({
      "foo" => 1,
      "bar" => 2 
    })
    expect(success[1]).to eq({
      "foo" => 3,
      "bar" => 4 
    })
  end

  it "handles missing values" do
    table = [
      ["foo", "bar"],
      [1],
    ]
    success, failure = subject.transform_enum(table)

    expect(success.size).to eq(1)
    expect(success[0]).to eq({
      "foo" => 1,
      "bar" => nil 
    })
  end

  
  it "preserves values without header keys by index" do
    table = [
      ["foo", " ", "bar"],
      [1,2,3,4],
    ]
    success, failure = subject.transform_enum(table)

    expect(success.size).to eq(1)
    expect(success[0]).to eq({
      "foo" => 1,
      1 => 2,
      "bar" => 3,
      3 => 4
    })
  end

  describe "whenc configured to drop unlabeled" do
    subject { described_class.new(drop_unlabeled: true) }

    it "doesn't preserve unlabeled values by default" do
      table = [
        ["foo", " ", "bar"],
        [1,2,3,4],
      ]
      success, failure = subject.transform_enum(table)

      expect(success.size).to eq(1)
      expect(success[0]).to eq({
        "foo" => 1,
        "bar" => 3,
      })
    end
    
  end
end
