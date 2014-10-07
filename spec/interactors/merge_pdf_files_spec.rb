require "spec_helper"

describe MergePdfFiles do
  subject { described_class }

  let(:files) { 
    [ Tempfile.new("f1"), Tempfile.new("f2") ]
  }
  let!(:paths) { files.map &:path }
  let(:pdf) { "the merged pdf content" }

  it "executes Ghostscirpt to merge pdf files, deletes the input files, and returns the PDF contenxt" do
    expect(GhostscriptWrapper).to receive(:merge_pdf_files).with(files).and_return(pdf)

    res = subject.perform(files: files)

    expect(res.pdf).to eq(pdf)

    paths.each do |path|
      expect(File.exist?(path)).not_to be_truthy
    end

  end

  it "requires :files" do
    expect { subject.perform() }.to raise_error(/:files/)
  end
end
