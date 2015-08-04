require 'spec_helper'

describe ProductImport::Transforms::ContriveKey do

  describe "with a single from key" do
    subject do
    end
    
    it "Contrives a key from the specified fields" do
      data = [
        {"foo" => "bar", "baz" = "qux"},
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)
      expect(successes[0]).to eq({"foo" => "bar"})

      expect(failures.size).to eq(1)
      expect(failures[0]).to eq({ "bad" => true })
    end
  end

end
