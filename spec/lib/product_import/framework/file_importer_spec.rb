require 'spec_helper'

# NOTE: Testing FileImporter api via introspection on Lodex.
# the following tests should be analogous for any file importer

describe ProductImport::FileImporters::Lodex do

  describe "the class" do
    subject { described_class }

    it "uses the CSV format" do
      expect(subject.format).to eq(:csv)
    end

    it "keeps the arguments and class in the format_spec" do
      expect(subject.format_spec).to eq({
        name: :csv,
        class: ::ProductImport::Formats::Csv,
        initialize_args: [],
      })
    end

    it "Initializes the required extract and canonicalize phases" do
      expect(subject.stage_spec_map.keys.to_set).to eq([:extract, :canonicalize].to_set)

      extract_stage = subject.stage_spec_map[:extract]
      expect(extract_stage[:name]).to eq(:extract)
      expect(extract_stage[:transforms]).to be_kind_of(Array)

      extract_stage = subject.stage_spec_map[:canonicalize]
      expect(extract_stage[:name]).to eq(:canonicalize)
      expect(extract_stage[:transforms]).to be_kind_of(Array)
    end

    it "Refuses to initialize an unknown stage" do
      expect{ subject.stage(:fuh){} }.to raise_error(ArgumentError)
    end

  end


  describe "An instance" do

    describe "#stage_named" do

      it "Doesn't respont to unknown stages" do
        expect{ subject.stage_named(:fuh) }.to raise_error(ArgumentError)
      end

      it "Returns an object representing the stage and caches it" do
        stage1 = subject.stage_named(:extract)

        expect(stage1).to be_kind_of(::ProductImport::Framework::ImportStage)

        expect(subject.stage_named(:extract).object_id).to eq(stage1.object_id)
      end

      it "has the metadata you'd expect" do 
        stage = subject.stage_named(:extract)
        expect(stage.name).to eq(:extract)

      end

      it "can be used to get a transform for the stage" do
        stage = subject.stage_named(:extract)
        t = stage.transform

        expect(t).to be_kind_of(::ProductImport::Framework::TransformPipeline)
        expect(t.transforms).to eq(stage.transforms)
      end
    end

    describe "#stages" do
      it "returns the stage objects in order" do
        expected = subject.stage_spec_map.keys.map{|k| 
          subject.stage_named(k)}

        expect(subject.stages).to eq(expected)
      end
    end

  end
end
