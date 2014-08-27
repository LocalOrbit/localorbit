require "spec_helper"

describe TwitterUser do
  it "removes @ from twitter slug" do
    result = TwitterUser.dump("@collectiveidea")
    expect(result).to eq("collectiveidea")
  end

  it "leaves the twitter slug alone if it doesn't start with @" do
    result = TwitterUser.dump("collectiveidea")
    expect(result).to eq("collectiveidea")
  end
end
