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

  describe ".ensure_user_has_subscription_link_to" do
    let!(:user) { create(:user, subscription_types:[]) }
    let!(:sub_type1) { create(:subscription_type, name:"The mag",keyword:"the_mag") }
    let!(:sub_type2) { create(:subscription_type, name:"A paper",keyword:"paper") }
    
    it "adds a new subscription, activated, if user has no subscription at all to the given type" do
      Subscription.ensure_user_has_subscription_link_to(user, subscription_type_keyword: sub_type1.keyword)
      expect(user.subscription_types).to contain_exactly(sub_type1)

      Subscription.ensure_user_has_subscription_link_to(user, subscription_type_keyword: sub_type2.keyword)
      expect(user.subscription_types).to contain_exactly(sub_type1,sub_type2)
    end

    it "doesn't modify or remove a soft-deleted subscription" do
      user.subscribe_to(sub_type1)
      sub = user.subscriptions.first
      sub.soft_delete
      expect(user.active_subscriptions).to be_empty

      Subscription.ensure_user_has_subscription_link_to(user, subscription_type_keyword: sub_type1.keyword)
      sub.reload
      expect(sub.deleted_at).to be
      expect(user.subscriptions).to contain_exactly(sub)
      expect(user.active_subscriptions).to be_empty
    end

    it "does nothing if the subscription type keyword doesn't match any actual types" do
      expect(user.subscriptions).to be_empty
      Subscription.ensure_user_has_subscription_link_to(user, subscription_type_keyword: "lol")
      expect(user.subscriptions).to be_empty
    end
  end

  describe ".ensure_user_has_subscription_links_to_fresh_sheet_and_newsletter" do
    let!(:user) { create(:user, subscription_types:[]) }
    let!(:fresh) { create(:subscription_type, :fresh_sheet) }
    let!(:news) { create(:subscription_type, :newsletter) }

    it "adds subscriptions to user for both types of sub" do
      expect(user.subscriptions).to be_empty
      Subscription.ensure_user_has_subscription_links_to_fresh_sheet_and_newsletter(user)
      expect(user.active_subscription_types).to contain_exactly(fresh,news)
    end
  end


end
