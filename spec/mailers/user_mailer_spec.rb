require "spec_helper"

describe UserMailer do
  describe "#user_updated" do
    let(:user) { double(:user, email: "user@test.com", primary_market: nil) }
    let(:updater) { double(:updater, email: "updater@test.com") }

    it "notifies a user that their account has been updated" do
      mailer = UserMailer.user_updated(user, updater, "user@test.com")

      expect(mailer).to deliver_to(["user@test.com"])
    end

    it "notifies a user's new and previous email if their email has been changed" do
      mailer = UserMailer.user_updated(user, updater, "original@test.com")

      expect(mailer).to deliver_to(["user@test.com", "original@test.com"])
    end
  end
end
