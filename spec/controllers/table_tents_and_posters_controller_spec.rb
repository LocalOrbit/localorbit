require "spec_helper"

describe TableTentsAndPostersController do

  include_context "the mini market"

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in barry
  end

  describe "#index" do
    it "sets the title and poster type" do
      get :index, order_id: 1, type: "poster"
      expect(assigns(:title)).to eq 'Posters (8.5" x 11")'
      expect(assigns(:printables)).to eq 'posters'
      get :index, order_id: 1
      expect(assigns(:title)).to eq 'Table Tents (4" x 6")'
      expect(assigns(:printables)).to eq 'table tents'
    end
  end

  [ "poster", "table_tent", nil ].each do |type_string|
    describe "Creating #{type_string || "default printable"}s..." do
      let(:printable_type) { type_string }
      let(:expected_printable_type) { type_string || "table tent" }
      let(:include_product_names) {[false, true].sample} #wink
      let(:intercom_event_type) {if type_string == "poster" then EventTracker::DownloadedPosters.name else EventTracker::DownloadedTableTents.name end}

      describe "#create" do
        def post_create
          if printable_type
            post :create, order_id: order.id, type: printable_type, include_product_names: include_product_names
          else
            post :create, order_id: order.id, include_product_names: include_product_names
          end
        end

        def expect_process_order_printable
          delayed_job = double "Delayed job"
          expect(ProcessOrderPrintable).to receive(:delay).and_return(delayed_job)
          expect(delayed_job).to receive(:perform) do |args|
            @delayed_job_args = args
          end
        end

        let (:order) {create(:order, market: mini_market, organization: buyer_organization)}
        let (:pdf_result) { double "PDF Result", data: "the pdf data" }

        it "inserts an OrderPrintable record per our inputs and starts a delayed job to process the PDF" do
          pre_count = OrderPrintable.all.size
          expect_process_order_printable

          post_create

          order_printable = OrderPrintable.where(order_id: order.id, printable_type: expected_printable_type).first
          expect(OrderPrintable.all.size).to eq pre_count + 1
          expect(order_printable).to be
          expect(order_printable.order.id).to eq order.id
          expect(order_printable.printable_type).to eq expected_printable_type
          expect(order_printable.include_product_names).to eq include_product_names

          expect(response).to redirect_to(order_table_tents_and_poster_path(order_id:order.id, id: order_printable.id))

          expect(@delayed_job_args).to be
          expect(@delayed_job_args[:order_printable_id]).to eq order_printable.id
          expect(@delayed_job_args[:request].base_url).to eq request.base_url

          e = EventTracker.previously_captured_events.first
          expect(e).to be
          expect(e).to eq({
            user: barry, 
            event: intercom_event_type, 
            metadata: {
              order: { 
                url: admin_order_url(order), 
                value: order.order_number
              }
            }
          })

        end
      end
    end
  end

  describe "#show" do
    let(:order_printable) {create :order_printable, user: barry}
    let(:order) {order_printable.order}

    context "GET html" do
      it "returns HTML" do
        get :show, order_id: order.id, id: order_printable.id
        expect(response.status).to eq 200
        expect(response.content_type).to eq "text/html"
      end

      context "when PDF is not available" do
        it "returns the JSON status with pdf_url nil" do
          get :show, order_id:order.id, id: order_printable.id, format: :json
          expect(response.status).to eq 200
          expect(response.content_type).to eq "application/json"
          data = JSON.parse(response.body)
          expect(data.keys).to contain_exactly("pdf_url")
          expect(data["pdf_url"]).to be_nil
        end
      end

      context "when PDF is  available" do
        before do
          order_printable.pdf = "mostly harmless"
          order_printable.pdf.name = "dolphins.pdf"
          order_printable.save
        end

        it "returns the JSON status with pdf_url set appropriately" do
          get :show, order_id:order.id, id: order_printable.id, format: :json
          expect(response.status).to eq 200
          expect(response.content_type).to eq "application/json"
          data = JSON.parse(response.body)
          expect(data.keys).to contain_exactly("pdf_url")
          expect(data["pdf_url"]).to_not be_nil
          order_printable_reloaded = OrderPrintable.find order_printable.id # BECUZ ARGH
          expect(data["pdf_url"]).to eq order_printable_reloaded.pdf.remote_url
        end
      end
    end
  end
end
