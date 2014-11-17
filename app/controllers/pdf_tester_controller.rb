class PdfTesterController < ApplicationController
  def index
    render_404 unless current_user.admin?
  end

  def generate
    render_404 unless current_user.admin?
    html = params[:html]
    if html =~ /^\s*file:/
      fname = html.split(":")[1].strip
      html = File.read(fname)
    end
    type = params[:type]

    pdf_settings = if type == "poster" 
                     {:page_size=>"letter", :margin_top=>0, :margin_right=>0, :margin_left=>0, :margin_bottom=>0}
                   else
                     {page_width: 101.6, page_height: 152.4, :margin_top=>0, :margin_right=>0, :margin_left=>0, :margin_bottom=>0}
                   end

    pdf_kit = PDFKit.new(html, pdf_settings)
    render text: pdf_kit.to_pdf, content_type: "application/pdf"
  end
end
