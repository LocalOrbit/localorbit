require "spec_helper"

describe Deliveries::PackingLabelsController do

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

    let (:delivery) {create(:delivery)}
    let (:pdf_result) { double "PDF Result", data: "the pdf data" }

    it "inserts an PackingLabelsPrintable record per our inputs and starts a delayed job to process the PDF" do
      before = PackingLabelsPrintable.where(delivery_id: delivery.id)
      expect(before).to be_empty

      expect_process_delivery_printable

      post_create

      delivery_printable = PackingLabelsPrintable.where(delivery_id: delivery.id).first
      expect(delivery_printable).to be

      expect(response).to redirect_to(admin_delivery_tools_delivery_packing_label_path(delivery_id: delivery.id, id: delivery_printable.id))

      expect(@delayed_job_args).to be
      expect(@delayed_job_args[:packing_labels_printable_id]).to eq delivery_printable.id
      expect(@delayed_job_args[:request].base_url).to eq request.base_url
    end
  end

  describe "#show" do
    let(:packing_labels_printable) {create :packing_labels_printable, user: barry}
    let(:delivery) {packing_labels_printable.delivery}

    context "GET html" do
      it "returns HTML" do
        get :show, delivery_id: delivery.id, id: packing_labels_printable.id
        expect(response.status).to eq 200
        expect(response.content_type).to eq "text/html"
      end

      context "when PDF is not available" do
        it "returns the JSON status with pdf_url nil" do
          get :show, delivery_id:delivery.id, id: packing_labels_printable.id, format: :json
          expect(response.status).to eq 200
          expect(response.content_type).to eq "application/json"
          data = JSON.parse(response.body)
          expect(data.keys).to contain_exactly("pdf_url")
          expect(data["pdf_url"]).to be_nil
        end
      end

      context "when PDF is  available" do
        before do
          packing_labels_printable.pdf = "mostly harmless"
          packing_labels_printable.pdf.name = "dolphins.pdf"
          packing_labels_printable.save
        end

        it "returns the JSON status with pdf_url set appropriately" do
          get :show, delivery_id:delivery.id, id: packing_labels_printable.id, format: :json
          expect(response.status).to eq 200
          expect(response.content_type).to eq "application/json"
          data = JSON.parse(response.body)
          expect(data.keys).to contain_exactly("pdf_url")
          expect(data["pdf_url"]).to_not be_nil
          packing_labels_printable_reloaded = PackingLabelsPrintable.find packing_labels_printable.id # BECUZ ARGH
          expect(data["pdf_url"]).to eq packing_labels_printable_reloaded.pdf.remote_url
        end
      end
    end
  end
end
