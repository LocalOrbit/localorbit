shared_context "fresh sheet and newsletter subscription types" do
  let!(:fresh_sheet_subscription_type) { create(:subscription_type, :fresh_sheet) }
  let!(:newsletter_subscription_type) { create(:subscription_type, :newsletter) }
end
