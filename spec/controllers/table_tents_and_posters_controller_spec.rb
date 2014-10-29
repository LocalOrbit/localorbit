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

      describe "#create" do
        def post_create
          if printable_type
            post :create, order_id: order.id, type: printable_type, include_product_names: false
          else
            post :create, order_id: order.id, include_product_names: false
          end
        end

        def expect_generate_pdf
          # expect(GenerateTableTentsOrPosters).to receive(:perform).
            # with(order: order, type: expected_printable_type, include_product_names: false).
            # and_return(context)
          expect(GenerateTableTentsOrPosters).to receive(:perform) do |arg|
            expect(arg[:order]).to eq(order)
            expect(arg[:type]).to eq(expected_printable_type)
            expect(arg[:include_product_name]).to be_falsey
            expect(arg[:request].base_url).to eq request.base_url
            context
          end
        end

        let (:order) {create(:order, organization: buyer_organization)}
        let (:pdf_result) { double "PDF Result", data: "the pdf data" }

        describe "when PDF generation succeeds" do
          let (:context) { double "Result Context", success?: true, pdf_result: pdf_result }

          it "renders the PDF data" do
            expect_generate_pdf
            post_create
            expect(response.content_type).to eq "application/pdf"
            expect(response.body).to eq pdf_result.data
          end
        end

        describe "when PDF generation fails" do
          let (:context) { double "Result Context", success?: false, message: "Too much want" }

          it "redirects to index and shows an error" do
            expect_generate_pdf
            post_create
            expect(response).to redirect_to([:order, :table_tents_and_posters, type: expected_printable_type])
            expect(flash[:alert]).to match(/generate.*#{expected_printable_type}/i)
          end
        end
      end
    end
  end
end
