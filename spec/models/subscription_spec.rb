require "spec_helper"

describe Subscription do

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  it "is created with a token" do
    sub = Subscription.create!

    expect(sub.token).to match(/[0-9a-f]*/i)
    expect(sub.token.length).to eq(32*2)
  end

end
