class GenerateInvoicePdf
  include Interactor

  def perform
    if context[:order].present? && order.invoiced? && !order.invoice_pdf.present?
      invoice = BuyerOrder.new(order)

      generate_pdf_for_invoice(invoice)

      fail! unless order.save
    end
  end

  def view
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.extend ApplicationHelper
    action_view.class_eval do
      include Rails.application.routes.url_helpers
    end
    action_view
  end

  def generate_pdf_for_invoice(invoice)
    html = view.render( template: "admin/invoices/show.html.erb", locals: { invoice: invoice, user: nil } )

    # If wkhtmltopdf gets an error downloading any media assets it will fail out
    # and the job will get rescheduled to run later.
    pdf = PDFKit.new(html, page_size: "letter", print_media_type: true)
    order.invoice_pdf = pdf.to_file("/tmp/#{order.order_number}.pdf")
  end
end
