class MakeInvoicePdfTempFile
  include Interactor

  def perform
    require_in_context(:order)

    invoice = BuyerOrder.new(order)
    file, pdf = generate_pdf_for_invoice(invoice)

    context[:file] = file
    context[:pdf] = pdf
  end
  
  private

  def generate_pdf_for_invoice(invoice)
    html = get_view.render( 
             template: "admin/invoices/show.html.erb", 
             locals: { 
               invoice: invoice, 
               user: nil})
    file = Tempfile.new("order_#{order.order_number}")
    pdf = PDFKit.new(html, page_size: "letter", print_media_type: true)
    return file, pdf.to_file(file.path)
  end

  def get_view
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.extend ApplicationHelper
    action_view.class_eval do
      include Rails.application.routes.url_helpers
    end
    action_view
  end

end
