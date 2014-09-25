require "spec_helper"

describe Subscription do

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  describe "token-related functions" do
    subject { Subscription.create! }

    it "is created with a token" do
      expect(subject.token).to match(/[0-9a-f]*/i)
      expect(subject.token.length).to eq(32*2)
    end

    it "can be unsubscribed by token" do
      expect(subject.deleted_at).to be_nil
      res = Subscription.unsubscribe_by_token(subject.token)
      expect(res).to eq(true)
      subject.reload
      expect(subject.deleted_at).to be
      expect(subject.deleted_at).to be_about(Time.current)
    end

    it "returns false if nil token given" do
      res = Subscription.unsubscribe_by_token(nil)
      expect(res).to eq(false)
    end

    it "returns false if token not found" do
      res = Subscription.unsubscribe_by_token("aaaaa")
      expect(res).to eq(false)
    end
    
  end

end
