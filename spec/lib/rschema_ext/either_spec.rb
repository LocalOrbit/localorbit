describe "'Either' extension to RSchema" do
  let(:organization) { Organization.new }
  let(:market) { Market.new }

  let(:schema) do 
    RSchema.schema { 
      either(Organization,Market, { type: String, id: Integer })
    }
  end

  it "provides a number of alernate schemas to try" do
    RSchema.validate!(schema, organization)
    RSchema.validate!(schema, market)
    RSchema.validate!(schema, {id: 5,type:"something"})
  end

  it "provides a compound validation error" do
    expect { RSchema.validate!(schema, 'oops') }.to raise_error(/is not a Organization, AND is not a Market, AND is not a Hash/)
  end

end
