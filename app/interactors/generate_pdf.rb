class GeneratePdf
  include Interactor

  def perform
    request, template, params, pdf_size = require_in_context :request, :template, :params, :pdf_size
    context[:pdf_result] = GeneratePdf.generate_pdf(request: request, template: template, params: params, pdf_size: pdf_size)
  end

  def self.generate_pdf(request:,template:,params:,pdf_size:)
    html = generate_html(request: request, template: template, params: params)
    if Figaro.env.debug == 'ON'
      puts ">>> HTML GENERATED USING template=#{template}, request=#{request.inspect} (base_url=#{request.base_url}) params=#{params.inspect} <<<"
      puts html
      puts ">>> END HTML <<<"
    end
    pdf_settings = pdf_size.merge({margin_top: 0, margin_right: 0, margin_left: 0, margin_bottom: 0})
    pdf_kit = PDFKit.new(html, pdf_settings)
    PdfResult.new(pdf_kit)
  end

  def self.generate_html(request:,template:,params:)
    locals = {params: params}
    view = get_view(request)
    view.render(
      template: template,
      locals: locals
    )
  end

  def self.get_view(request)
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {})
    action_view.request = request
    action_view.extend ApplicationHelper
    action_view.class_eval do
      include Rails.application.routes.url_helpers
    end
    action_view
  end
end
