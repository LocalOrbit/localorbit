class TemplatedPdfGenerator
  ZeroMargins = { margin_top: 0, margin_left: 0, margin_right: 0, margin_bottom: 0 }

  class << self
    def generate_pdf(request:, template:, locals:, pdf_settings:{}, path:nil )
      html = HtmlTemplateRenderer.generate_html(
        request: request, 
        template: template, 
        locals: locals)

      # pdf_settings = pdf_settings.merge(ZeroMargins)

      if Figaro.env.debug == 'ON'
        pref = ">>> DEBUG TemplatedPdfGenerator:"
        puts "#{pref} HTML FROM template=#{template}, request=#{request.inspect} (base_url=#{request.base_url}) locals=#{locals.inspect}"
        puts html
        puts "#{pref} (END HTML)"
        puts "#{pref} PDF_SETTINGS: #{pdf_settings.inspect} <<<"
      end

      return HtmlToPdfConverter.generate_pdf(html: html, pdf_settings: pdf_settings, path: path)
    end
  end
end
