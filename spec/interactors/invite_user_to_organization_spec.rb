require "spec_helper"

describe InviteUserToOrganization do
  let(:org) { create(:organization) }
  let(:inviter) { create(:user, :market_manager) }
  let(:market) { inviter.managed_markets.first }
  subject(:interactor) do
    InviteUserToOrganization.new(interactor_args)
  end

  before do
    inviter.organizations << org
    market.organizations << org
  end

  describe "when a user doesn't exist in the system" do
    let(:interactor_args) do
      {email: "frank@example.com", inviter: inviter, organization: org}
    end

    it "creates the user" do
      expect {
        subject.perform
        expect(subject).to be_success
      }.to change {
        User.count
      }.by(1)
    end

    it "associates the user with the organization" do
      subject.perform
      expect(subject.context[:user].organizations).to include(org)
    end

    it "sends a 'You have been invited to Local Orbit' email" do
      subject.perform
      open_email("frank@example.com")

      expect(current_email).to have_subject("You have been invited to #{org.name}")
      expect(current_email).to have_body_text("You have been invited to join #{org.name}") # Messaging made more generic to account for RYO
    end

    it "Fails on an invalid email address" do
      subject.context[:email] = "asdfasdf"
      subject.perform
      expect(subject).to_not be_success
      expect(subject.message).to eq("Email is invalid")
    end

    it "Fails with a blank email address" do
      subject.context[:email] = ""
      subject.perform
      expect(subject).to_not be_success
      expect(subject.message).to eq("Email can't be blank")
    end
  end

  describe "an existing user" do
    let(:user) { create(:user, :admin) }
    let(:user_org) { create(:organization) }
    let(:interactor_args) do
      {email: user.email.upcase, inviter: inviter, organization: org, market: market}
    end

    before do
      user.organizations << user_org
      market.organizations << user_org
    end

    it "does not create a new user" do
      expect {
        subject.perform
        expect(subject).to be_success
      }.to_not change {
        User.count
      }
    end

    it "sends a 'You have been invited to an orgainization' email" do
      subject.perform

      open_email(user.email)
      expect(current_email).to have_subject("You have been added to an organization")
      expect(current_email).to have_body_text("You have been invited to join #{org.name} by a member of your organization.")
    end

    it "associates the user with the new organization" do
      expect(user.organizations(true)).to_not include(org)

      subject.perform

      expect(user.organizations(true)).to include(org)
    end
  end

  describe "a user that's already in the organization" do
    let(:user) { create(:user, :admin) }
    let(:org) { create(:organization) }
    let(:interactor_args) do
      {email: user.email, inviter: inviter, organization: org}
    end

    before do
      user.organizations << org
    end

    it "does not send an email to the user" do
      subject.perform
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it "does not duplicate the association" do
      expect {
        subject.perform
      }.to_not change {
        user.organizations(true)
      }
    end

    it "reports a simple error message" do
      subject.perform
      expect(subject).to_not be_success
      expect(subject.context[:message]).to eq("You have already added this user")
    end

    context "who has not accepted their invitation" do
      before do
        user.invite!(user)
        ActionMailer::Base.deliveries.clear
      end

      it "resends their invitation email" do
        subject.perform
        open_last_email_for(user.email)

        expect(current_email.subject).to eq("You have been invited to #{org.name}")
      end
    end
  end
end
