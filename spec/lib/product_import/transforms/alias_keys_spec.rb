require 'spec_helper'

describe ProductImport::Transforms::AliasKeys do
  subject {described_class.new(key_map: { "FOO" => "foo", "BAR" => "bar2" })}

  it "aliases the keys in a row given a map" do

    data = [
      {"FOO" => "A", "BAR" => "B"},
      {"FOO" => "C"}
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(2)
    expect(successes[0]).to eq({"foo" => "A", "bar2" => "B", "FOO"=>"A", "BAR"=>"B"})
    expect(successes[1]).to eq({"foo" => "C", "FOO"=>"C"})
  end

end
