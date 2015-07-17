require 'spec_helper'

describe "'Regexp' extension to RSchema" do
  let(:schema) do 
    RSchema.schema { 
      /foo/
    }
  end

  it "provides a number of alernate schemas to try" do
    RSchema.validate!(schema, "foooo")
    RSchema.validate!(schema, "ofoo")
  end

  it "provides a compound validation error" do
    expect { RSchema.validate!(schema, :foo) }.to raise_error(/is not a String matching \/foo\//)
    expect { RSchema.validate!(schema, 'oops') }.to raise_error(/is not a String matching \/foo\//)
    expect { RSchema.validate!(schema, nil) }.to raise_error(/is not a String matching \/foo\//)
  end

end
