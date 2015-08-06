require 'spec_helper'

describe ProductImport::Transforms::CoerceKeys do

  subject do
    described_class.new map: {
      "foo" => :to_s,
      "int" => :to_i,
      "float" => :to_f,
    }
  end
  it "does something" do
    data = [
      {"foo" => :bar, "int" => "32", "float" => "1.8"},
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)
    expect(successes[0]).to eq({
      "foo" => 'bar',
      "int" => 32,
      "float" => 1.8
    })

    expect(failures.size).to eq(0)
  end

end
