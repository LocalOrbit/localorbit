require 'spec_helper'

describe ProductImport::Transforms::LookUpUnit do

  let!(:unit1) { create :unit }


  it "sets the unit id to the second level deep unit with matching plural" do
    data = [
      {"unit" => unit1.plural},
      {"bad" => true},
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)
    expect(successes[0]).to eq({"unit" => unit1.plural, "unit_id" => unit1.id})

    expect(failures.size).to eq(1)
  end

end
