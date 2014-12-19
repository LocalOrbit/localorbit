describe HtmlTemplateRenderer do
  subject { described_class }

  def generate_html
    subject.generate_html(
      request: request,
      template: template,
      locals: locals
    )
  end

  let(:base_url) { "http://base.url:4545" }
  let(:request) { double "request", base_url: base_url }
  let(:template) { "dashboards/coming_soon" }
  let(:locals) { {} }

  it "can generate the Coming Soon page" do
    html = generate_html
    expect(html).to match(/<h2>Coming Soon<\/h2>/)
  end

  context "when parameterized" do
    let(:template) { "test/a_template" }
    let(:locals) {{ lunch_place: "The Restaurant At The End Of The Universe",
                    image_name: "milliways.png" }}
    it "can use locals generate links with the proper base url" do
      html = generate_html
      expect(html).to match(/Having lunch at The Restaurant At The End Of The Universe/)
      expect(html).to match(/src="#{base_url}\/milliways\.png"/)
    end
  end



end
