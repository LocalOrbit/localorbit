require 'spec_helper'

describe ProductImport::Transforms::ContriveKey do

  describe "with a single from key" do
    subject do
      described_class.new(
        from: ["baz","moo","cluck","desc"] # mimic: organization name unit unit_description
      )
    end
    
    it "Contrives a key from the specified fields" do
      data = [
        {"foo" => "bar", "baz" => "qux", "moo" => "quack","cluck" => "baa", "desc" => "too"},
        {"bad" => true}
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)
      expected_key = ExternalProduct.contrive_key(["QUX","QUACK","BAA","TOO"])

      expect(successes[0]).to eq({"foo" => "bar", "baz" => "qux", "moo" => "quack","cluck" => "baa", "desc" => "too","contrived_key" => expected_key})

      expect(failures.size).to eq(1)
      expect(failures[0][:raw]).to eq({ "bad" => true, "contrived_key" => nil })
    end

    # TODO must regenerate contrived key field before merging this in
    # This test goes away because there aren't two scenarios here anymore (product codes along for the ride)
    # it "Correctly manages products with no product code" do
    #   data = [
    #       {"foo" => "", "baz" => "qux", "moo" => "quack", "cluck" => "baa"},
    #       {"bad" => true, "contrived_key" => nil}
    #     ]
    #   successes, failures = subject.transform_enum(data)

    #   expect(successes.size).to eq(1)

    #   expected_key = "09gRZ45j3+YRI8ZkNjvIx74AVVw" # == ExternalProduct.contrive_key(["qux","quack","baa"]) 

    #   expect(successes[0]).to eq({"foo" => "", "baz" => "qux", "moo" => "quack","cluck" => "baa","contrived_key" => expected_key})

    #   expect(failures.size).to eq(1)
    #   expect(failures[0][:raw]).to eq({ "bad" => true, "contrived_key" => nil })

    # end
  end
  
end
