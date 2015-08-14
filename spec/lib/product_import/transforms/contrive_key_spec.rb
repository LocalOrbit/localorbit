require 'spec_helper'

describe ProductImport::Transforms::ContriveKey do

  describe "with a single from key" do
    subject do
      described_class.new(
        from: ["foo","baz","moo","cluck"]
      )
    end
    
    it "Contrives a key from the specified fields" do
      data = [
        {"foo" => "bar", "baz" => "qux", "moo" => "quack","cluck" => "baa"},
        {"bad" => true }
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)

      expected_key = "Ys23Ag/5IOWqZCw9QGaVDdHwH00" # == ExternalProduct.contrive_key(["bar"])

      expect(successes[0]).to eq({"foo" => "bar", "baz" => "qux", "moo" => "quack","cluck" => "baa","contrived_key" => expected_key})

      expect(failures.size).to eq(1)
      expect(failures[0][:raw]).to eq({ "bad" => true })
    end

    it "Correctly manages products with no product code" do
      data = [
          {"foo" => "", "baz" => "qux", "moo" => "quack", "cluck" => "baa"},
          {"bad" => true }
        ]
      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)

      expected_key = "09gRZ45j3+YRI8ZkNjvIx74AVVw" # == ExternalProduct.contrive_key(["qux","quack","baa"]) 

      expect(successes[0]).to eq({"foo" => "", "baz" => "qux", "moo" => "quack","cluck" => "baa","contrived_key" => expected_key})

      expect(failures.size).to eq(1)
      expect(failures[0][:raw]).to eq({ "bad" => true })

    end
  end

  

end
