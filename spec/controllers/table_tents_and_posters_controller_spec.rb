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

  [ "poster", "table_tent" ].each do |type_string|
    describe "Creating #{type_string}s..." do
      let(:printable_type) { type_string }

      describe "#create", :wip=>true do
        def expect_generate_pdf
          expect(GenerateTableTentsOrPosters).to receive(:perform).
            with(order: order, type: printable_type, include_product_names: false).
            and_return(context)
        end

        let (:order) {create(:order, organization: buyer_organization)}
        let (:pdf_result) { double "PDF Result", data: "the pdf data" }

        describe "when PDF generation succeeds" do
          let (:context) { double "Result Context", success?: true, pdf_result: pdf_result }

          it "renders the PDF data" do
            expect_generate_pdf
            post :create, order_id: order.id, type: printable_type, include_product_names: false
            expect(response.content_type).to eq "application/pdf"
            expect(response.body).to eq pdf_result.data 
          end
        end

        describe "when PDF generation fails" do
          let (:context) { double "Result Context", success?: false, message: "Too much want" }

          it "redirects to index and shows an error" do
            expect_generate_pdf
            post :create, order_id: order.id, type: printable_type, include_product_names: false
            expect(response).to redirect_to([:order, :table_tents_and_posters, type: printable_type])

            expect(flash[:alert]).to match(/generate.*#{printable_type}/i)
          end
        end
      end
    end
  end
end
