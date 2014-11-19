describe TemplatedPdfGenerator do
  subject { described_class }

  let(:html)         { "the html" }
  let(:request)      { double "request", base_url: "the base url" }
  let(:template)     { "the template" }
  let(:locals)       { {the:"locals"} }
  let(:pdf_settings) { { the:"pdf size info" } }
  let(:path)         { "pdf file path" }
  let(:pdf_result)   { "the pdf result" }

  it "renders an HTML template and feeds it through the PDF converter" do
    expect(HtmlTemplateRenderer).to receive(:generate_html).
      with(request: request,
           template: template,
           locals: locals).
      and_return(html)

    expect(HtmlToPdfConverter).to receive(:generate_pdf).
      with(html: html, 
           pdf_settings: pdf_settings,
           path: path).
      and_return(pdf_result)

    res = TemplatedPdfGenerator.generate_pdf(
      request: request,
      template: template,
      locals: locals,
      pdf_settings: pdf_settings,
      path: path
    )
    expect(res).to eq(pdf_result)
  end


  context "when optional pdf_settings arg is omitted" do
    it "sends empty hash" do
      expect(HtmlTemplateRenderer).to receive(:generate_html).
        with(request: request,
             template: template,
             locals: locals).
        and_return(html)

      expect(HtmlToPdfConverter).to receive(:generate_pdf).
        with(html: html, 
             pdf_settings: {},
             path: path).
        and_return(pdf_result)

      res = TemplatedPdfGenerator.generate_pdf(
        request: request,
        template: template,
        locals: locals,
        # no pdf_settings
        path: path
      )
      expect(res).to eq(pdf_result)
    end
  end

  context "when optional path arg is omitted" do
    it "passes nil path to the converter" do
      expect(HtmlTemplateRenderer).to receive(:generate_html).
        with(request: request,
             template: template,
             locals: locals).
        and_return(html)

      expect(HtmlToPdfConverter).to receive(:generate_pdf).
        with(html: html, 
             pdf_settings: pdf_settings,
             path: nil).
        and_return(pdf_result)

      res = TemplatedPdfGenerator.generate_pdf(
        request: request,
        template: template,
        locals: locals,
        pdf_settings: pdf_settings
        # no path
      )
      expect(res).to eq(pdf_result)
    end
  end


end
