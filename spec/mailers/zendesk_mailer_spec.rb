require "spec_helper"

describe ZendeskMailer do
  let(:user) { build(:user) }

  describe "request_unit" do
    let(:params) do
      {
        singular: "fathom",
        plural: "fathoms",
        additional_notes: "See more notes"
      }
    end

    it "sends a new unit request to the admins" do
      fresh_sheet = ZendeskMailer.request_unit(user, params)
      #expect(fresh_sheet.from).to include(user.email)
      expect(fresh_sheet.body).to include(user.name)
      expect(fresh_sheet.body).to include(params[:singular])
      expect(fresh_sheet.body).to include(params[:plural])
      expect(fresh_sheet.body).to include(params[:additional_notes])
    end
  end

  describe "request_category" do
    let(:category) { "Meat/Spam" }

    it "sends a new unit request to the admins" do
      fresh_sheet = ZendeskMailer.request_category(user, category)
      #expect(fresh_sheet.from).to include(user.email)
      expect(fresh_sheet.body).to include(user.name)
      expect(fresh_sheet.body).to include(category)
    end
  end

  describe "error_intervention" do
    it "sends a message to the admins about the error" do
      email = ZendeskMailer.error_intervention(user, "Bad Error", thing: "stuff")
      #expect(email.from).to include(user.email)
      expect(email.subject).to include("Bad Error")
      expect(email.body).to include("thing")
      expect(email.body).to include("stuff")
    end
  end
end
