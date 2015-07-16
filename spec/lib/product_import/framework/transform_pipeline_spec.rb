require 'spec_helper'

describe ProductImport::Framework::TransformPipeline do
  class AddTransform < ProductImport::Framework::Transform
    def initialize(opts)
      super
      @adds = opts[:adds]
    end

    def transform_step(input)
      if input.is_a? Numeric
        @adds.each do |add|
          continue input + add
        end
      else
        reject "Not a number"
      end
    end
  end

  describe "With multiple transforms" do
    subject {
      t1 = AddTransform.new(
        adds: [1],
        stage: "parse",
        desc: "Add 1"
      )

      t2 = AddTransform.new(
        adds: [2,3],
        stage: "parse",
        desc: "Add 2 and 3"
      )

      ProductImport::Framework::TransformPipeline.new(
        transforms: [t1,t2]
      )
    }

    it "stacks the results." do
      successes, failures = subject.transform_enum([1,:foo, 2,"bar", 3])

      expect(successes).to eq([4, 5, 5,6, 6, 7])
      expect(failures.length).to eq(2)

      expect(failures[0]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1",
        "raw" => :foo,
      })

      expect(failures[1]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1",
        "raw" => 'bar',
      })
    end

    it "handles empty enums" do
      successes, failures = subject.transform_enum([])

      expect(successes).to eq([])
      expect(failures).to eq([])
    end
  end

  describe "a single transform" do
    subject {
      t1 = AddTransform.new(
        adds: [1],
        stage: "parse",
        desc: "Add 1"
      )


      ProductImport::Framework::TransformPipeline.new.tap{|t|
        t.transforms = [t1]
      }
    }

    it "Can create success/failure sets for an input" do
      successes, failures = subject.transform_enum([1,:foo, 2,"bar", 3])

      expect(successes).to eq([2,3,4])
      expect(failures.length).to eq(2)

      expect(failures[0]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1",
        "raw" => :foo,
      })

      expect(failures[1]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1",
        "raw" => 'bar',
      })
    end

    it "handles empty enums" do
      successes, failures = subject.transform_enum([])

      expect(successes).to eq([])
      expect(failures).to eq([])
    end
  end



  describe "with an empty set of transforms" do
    subject do
      ProductImport::Framework::TransformPipeline.new(
        transforms: []
      )
    end

    it "simply passes through all values" do
      successes, failures = subject.transform_enum([1,:foo, 3])

      expect(successes).to eq([1, :foo, 3])
      expect(failures.length).to eq(0)
    end
  end


  describe "a subclass using the DSL" do
    class MyTransform < ProductImport::Framework::TransformPipeline
      transform :set_keys_to_importer_option_values, map: {
        "market_id" => :market_id
      }

      transform :set_keys_to_importer_option_values, map: {
        organization_id: :organization_id
      }
    end

    subject do
      importer = double("importer", {
        opts: {
          market_id: 1,
          organization_id: 2,
        }
      })

      MyTransform.new(
        importer: importer
      )
    end

    it "instantiates the transforms and applies them in sequence" do
      successes, failures = subject.transform_enum([{}])

      expect(successes).to eq([{
        "market_id" => 1,
        "organization_id" => 2,
      }])
      expect(failures.length).to eq(0)
    end
  end
end

