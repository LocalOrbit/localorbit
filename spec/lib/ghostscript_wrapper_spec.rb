require 'spec_helper'

RSpec.describe GhostscriptWrapper do

  describe '.merge_pdf_files' do
    let(:pdf_file) { File.new(Pathname.new(Rails.root).join('spec/fixtures/test.pdf')) }
    let(:pdf_files) { [pdf_file, pdf_file] }

    it 'does not raise' do
      expect { GhostscriptWrapper.merge_pdf_files(pdf_files) }.not_to raise_error
    end

    it 'returns a pdf' do
      expect(GhostscriptWrapper.merge_pdf_files(pdf_files).index("%PDF-1.5\n")).to eq 0
    end
  end

end
