require 'spec_helper'

describe ProductImport::Transforms::FromFlatTable do
  subject {
    described_class.new({
      required_headers: ["foo", "bar"]
    })
  }

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


  it "rejects data if a required header is missing" do
    table = [
      ["foo", ""],
      [1, ""]
    ]
    success, failure = subject.transform_enum(table)

    expect(success).to eq([])
    expect(failure.size).to eq(2)
    expect(failure[0]).to eq({:reason=>"Missing keys bar", :stage=>nil, :transform=>nil, :raw=>["foo", ""]})
    expect(failure[1]).to eq({:reason=>"Missing keys bar", :stage=>nil, :transform=>nil, :raw=>[1, ""]})
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

  describe "when configured to drop unlabeled" do
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
