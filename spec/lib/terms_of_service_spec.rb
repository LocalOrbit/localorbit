require 'spec_helper'

describe TermsOfService do
	subject { described_class } 
	let(:user) { create(:user) }

	it "creates a user with appropriate attributes" do
		t = Time.now
		subject.accept(user:user,time:t,ip_addr:"fakeipaddress") 
		user.reload
		expect(user.accepted_terms_of_service_at).to eq(t.to_date)
        expect(user.accepted_terms_of_service_from).to eql("fakeipaddress")
	end
end