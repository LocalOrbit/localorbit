shared_context "intercom enabled" do
  before do
    allow_any_instance_of(ApplicationController).to receive(:intercom_enabled?).and_return(true)
  end
end
