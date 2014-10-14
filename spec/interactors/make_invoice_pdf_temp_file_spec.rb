require "spec_helper"

describe "MakeInvoicePdfTempFile interactor" do
  let!(:order) { create(:order) }
  let(:request) { double("Request", base_url: "http://test.com:3030") }

  let(:html) { render_html_view(request,order) }

  it "builds a document using PDFKit" do
    expect(order.invoice_pdf).to be_nil
    expect(PDFKit).to receive(:new).once.with(html, page_size:"letter",print_media_type:true).and_return(double("PDFKit double", to_file: "The PDF"))

    context = MakeInvoicePdfTempFile.perform(request: request, order: order)
    expect(context.file).to be_a Tempfile
    expect(context.file.path).to match(/order_#{order.order_number}/)
    expect(context.pdf).to eq("The PDF")
    expect(context.document_name).to eq("#{order.order_number}.pdf")

    expect(order.invoice_pdf).to be_nil
  end

  it "requires an Order" do
    expect { MakeInvoicePdfTempFile.perform(request:request) }.to raise_error(/:order/)
  end

  it "requires a Request" do
    expect { MakeInvoicePdfTempFile.perform(order:order) }.to raise_error(/:request/)
  end

  #
  # HELPERS
  #

  def render_html_view(request,order)
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.request = request
    action_view.extend ApplicationHelper
    action_view.class_eval do
      include Rails.application.routes.url_helpers
    end
    action_view.render(template: "admin/invoices/show.html.erb",
                       locals: {
                         invoice: BuyerOrder.new(order),
                         user: nil
                       })
  end
end

