require 'spec_helper'

# NOTE: Testing FileImporter api via introspection on Lodex.
# the following tests should be analogous for any file importer

describe ProductImport::Framework::FileImporter do
  let(:described_class) { ProductImport::FileImporters::Lodex }

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
      expect(subject.stage_spec_map.keys.to_set).to eq(ProductImport::Framework::FileImporter::ALLOWED_STAGES.to_set)

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

      it "Doesn't respond to unknown stages" do
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
        expect(t.transforms.map(&:spec)).to eq(stage.transforms.map(&:spec))
      end
    end

    describe "#stages" do
      it "returns the stage objects in order" do
        expected = subject.stage_spec_map.keys.map{|k| 
          subject.stage_named(k)}

        expect(subject.stages).to eq(expected)
      end
    end

    describe "resolve stage" do
      let!(:market1) { create(:market) }
      let!(:org1) { create(:organization, :seller) }
      subject { described_class.new(market_id:market1.id).stage_named(:resolve) }

      before do 
        market1.organizations << org1 
        market1.save
      end

      it "adds in market id, org id, and category id" do
        data = [{
        "category" => "Tropical & Specialty", # this is included in the extant categories in test
        "name" => "SARA LEE BAGEL PLAIN PRESLICED",
        "price" => 24.03,
        "product_code" => 10300,
        "organization" => org1.name,
        "contrived_key" => ExternalProduct.contrive_key(['10300']),
        "source_data" => {
          "Seller Name"=>"Bi-Rite",
          "Product Name"=>"SARA LEE BAGEL PLAIN PRESLICED",
          "Category Name"=>"Miscellaneous",
          "Short Description"=>"72 / 3 OZ",
          "Supplier Product Number"=>10300,
          "Unit Name"=>"Each",
          "Unit Description (optional)"=>"72 / 3 OZ",
          "Price"=>24.03,
          "Customer Category"=>"BAKED GOODS",
          "Customer Unit of Measure"=>"3 OZ",
          "Customer Original Price"=>24.03,
          12=>1},

        "unit" => "72 / 3 OZ",
        "uom" => "Each",
        }]

        success, fail = subject.transform.transform_enum(data)

        success_row = success.first

        expect(success.length).to eq(1)
        expect(fail.length).to eq(0)

        expect(success_row['market_id']).to eq(market1.id)
        expect(success_row['category_id']).to_not be_nil # for now
        expect(success_row['organization_id']).to be 

      end
    end

  end
end
