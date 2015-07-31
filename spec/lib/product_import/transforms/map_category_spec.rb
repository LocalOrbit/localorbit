require 'spec_helper'

describe ProductImport::Transforms::MapCategory do
  describe "mapping file exists" do
    subject {
      described_class.new(
        filename: 'pacific_gourmet.csv',
        input_key: 'vendor category'
      )
    }

    it "maps the category from the input file to the keys defined in a given csv" do
      data = [
        {"vendor category" => "ASIAN NOODLES"},
      ]

      successes, failures = subject.transform_enum(data)

      expect(failures).to eq([])
      expect(successes.size).to eq(1)
      expect(successes[0]).to eq({"vendor category"=>"ASIAN NOODLES", "category"=>"Pasta > Dried Pasta > Asian Noodles"})
    end

    it "rejects rows where the input category cannot be mapped with the given file" do
      data = [
        {"vendor category"=>"UNICORN BLOOD"}
      ]

      successes, failures = subject.transform_enum(data)

      expect(failures).to eq([{:reason=>"Category UNICORN BLOOD not found in pacific_gourmet.csv", :stage=>nil, :transform=>nil, :raw=>{"vendor category"=>"UNICORN BLOOD"}}])
      expect(successes).to eq([])
    end
  end

  describe "mapping file not found" do
    subject {
      described_class.new(
        filename: 'imaginary_file.csv',
        input_key: 'vendor category'
      )
    }

    it "raises an exception" do
      expect {subject.transform_enum([])}.to raise_error
    end
  end
end
