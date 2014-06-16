require "spec_helper"

describe ZendeskMailer do
  describe "request_unit" do
    let(:email) { "requester@example.com" }
    let(:name) { "Requester Person" }
    let(:params) {{
      singular: "fathom",
      plural: "fathoms",
      additional_notes: "See more notes"
    }}

    it "sends a new unit request to the admins" do
      fresh_sheet = ZendeskMailer.request_unit(email, name, params)
      expect(fresh_sheet.from).to include(email)
      expect(fresh_sheet.body).to include(name)
      expect(fresh_sheet.body).to include(params[:singular])
      expect(fresh_sheet.body).to include(params[:plural])
      expect(fresh_sheet.body).to include(params[:additional_notes])
    end
  end

  describe "request_category" do
    let(:email) { "requester@example.com" }
    let(:name) { "Requester Person" }
    let(:category) { "Meat/Spam" }

    it "sends a new unit request to the admins" do
      fresh_sheet = ZendeskMailer.request_category(email, name, category)
      expect(fresh_sheet.from).to include(email)
      expect(fresh_sheet.body).to include(name)
      expect(fresh_sheet.body).to include(category)
    end
  end
end
