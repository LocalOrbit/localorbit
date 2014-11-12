require "spec_helper"

describe Deliveries::PackingLabelsController, wip:true do

  include_context "the mini market"

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in barry
  end

  describe "#create" do
    def post_create
      post :create, delivery_id: delivery.id
    end

    def expect_process_delivery_printable
      delayed_job = double "Delayed job"
      expect(ProcessPackingLabelsPrintable).to receive(:delay).and_return(delayed_job)
      expect(delayed_job).to receive(:perform) do |args|
        @delayed_job_args = args
      end
    end

    let (:delivery) {create(:delivery, organization: buyer_organization)}
    let (:pdf_result) { double "PDF Result", data: "the pdf data" }

    it "inserts an PackingLabelsPrintable record per our inputs and starts a delayed job to process the PDF" do
      pre_count = PackingLabelsPrintable.all.size
      expect_process_delivery_printable

      post_create

      delivery_printable = PackingLabelsPrintable.where(delivery_id: delivery.id, printable_type: expected_printable_type).first
      expect(PackingLabelsPrintable.all.size).to eq pre_count + 1
      expect(delivery_printable).to be
      expect(delivery_printable.delivery.id).to eq delivery.id
      expect(delivery_printable.printable_type).to eq expected_printable_type
      expect(delivery_printable.include_product_names).to eq include_product_names

      expect(response).to redirect_to(delivery_table_tents_and_poster_path(delivery_id:delivery.id, id: delivery_printable.id))

      expect(@delayed_job_args).to be
      expect(@delayed_job_args[:delivery_printable_id]).to eq delivery_printable.id
      expect(@delayed_job_args[:request].base_url).to eq request.base_url
    end
  end
end
