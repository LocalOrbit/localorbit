require 'spec_helper'

describe ProductImport::Transforms::LookUpCategory do
  let!(:category1) { Category.find_by_name_and_depth("Apples",2) }

  it "sets the category id to the second level deep category with matching name" do
    
    data = [
      {"category" => "Apples"},
      {"category" => "All"},
      {"bad" => true},
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)
    expect(successes[0]).to eq({"category" => "Apples", "category_id" => category1.id})

    expect(failures.size).to eq(2)
  end

end
