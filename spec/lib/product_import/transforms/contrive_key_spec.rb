require 'spec_helper'

describe ProductImport::Transforms::ContriveKey do

  describe "with a single from key" do
    subject do
      described_class.new(
        from: ["foo"]
      )
    end
    
    it "Contrives a key from the specified fields" do
      data = [
        {"foo" => "bar", "baz" => "qux"},
        {"bad" => true }
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)

      expected_key = "Ys23Ag/5IOWqZCw9QGaVDdHwH00" # == ExternalProduct.contrive_key(["bar"])

      expect(successes[0]).to eq({"foo" => "bar", "baz" => "qux", "contrived_key" => expected_key})

      expect(failures.size).to eq(1)
      expect(failures[0][:raw]).to eq({ "bad" => true })
    end
  end

end
