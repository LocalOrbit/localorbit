require 'spec_helper'

describe ProductImport::Transforms::<%= class_name %> do

  it "does something" do
    # TODO: implement real tests

    data = [
      {"foo" => "bar"},
      {"bad" => true},
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)
    expect(successes[0]).to eq({"foo" => "bar"})

    expect(failures.size).to eq(1)
    expect(failures[0]).to eq({ "bad" => true })
  end

end
