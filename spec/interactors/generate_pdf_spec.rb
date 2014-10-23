require "spec_helper"

describe GeneratePdf do
  let(:request) {double("request", {:base_url=>"http://www.example.com"})}

  it "generates a pdf given valid parameters" do
    template = "dashboards/coming_soon"
    params = {}
    pdf_size = {page_size: "letter"}

    context = GeneratePdf.perform(request: request, template: template, params: params, pdf_size: pdf_size)
    expect(context.pdf_result.data.match(/^%PDF-1.4/)).to_not eq nil
  end

  it "throws an exception given invalid parameters" do
    expect {GeneratePdf.perform}.to raise_error
    expect {GeneratePdf.perform( template: "dashboards/coming_soon", params: {}, pdf_size: {})}.to raise_error(/request/)
    expect {GeneratePdf.perform(request: request, params: {}, pdf_size: {})}.to raise_error(/template/)
  end

  it "throws an exception for bad template" do
    template = "towel"
    params = {}
    pdf_size = {page_size: "letter"}
    expect {GeneratePdf.perform(request: request, template: template, params: params, pdf_size: pdf_size)}.to raise_error(/template/)
  end
end