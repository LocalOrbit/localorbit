class GeneratePdf
  include Interactor

  def perform
    request, template, params, pdf_size = require_in_context :request, :template, :params, :pdf_size
    context[:pdf] = generate_pdf(request: request, template: template, params: params)
  end

  def generate_pdf(request:,template:,params:)
    html = generate_html(request: request, template: template, params: params)
    pdf_settings = pdf_size.merge({margin_top: 0, margin_right: 0, margin_left: 0, margin_bottom: 0})
    pdf_kit = PDFKit.new(html, pdf_settings)
    pdf_kit.to_pdf
  end

  def generate_html(request:,template:,params:)
    locals = {params: params}
    view = get_view(request)
    view.render(
      template: template,
      locals: locals
    )
  end

  def get_view(request)
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.request = request
    action_view.extend ApplicationHelper
    action_view.class_eval do
      include Rails.application.routes.url_helpers
    end
    action_view
  end
end