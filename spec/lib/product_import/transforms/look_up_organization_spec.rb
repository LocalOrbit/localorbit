require 'spec_helper'

describe ProductImport::Transforms::LookUpOrganization do
  let!(:market1) { create(:market) }
  let!(:org1) { create(:organization, :seller) }
  let!(:non_market_org) { create(:organization, :seller) }

  before do 
    market1.organizations << org1 
    market1.save
    subject.importer = double "FileImporter", opts:{market_id:market1.id}
  end

  it "sets the organization id to be an organization of the right market" do
    
    data = [
      {"organization" => org1.name},
      {"organization" => non_market_org.name},
      {"bad" => true},
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)
    expect(successes[0]).to eq({"organization" => org1.name, "organization_id" => org1.id})

    expect(failures.size).to eq(2)
  end

end
