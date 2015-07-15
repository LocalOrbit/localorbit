require 'spec_helper'

describe ProductImport::Framework::TransformPipeline do
  describe "With multiple transforms" do
    class AddTransform < ProductImport::Framework::Transform
      def initialize(adds)
        @adds = adds
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

      subject {
      t1 = AddTransform.new([1]).tap{|t|
        t.stage = "parse"
        t.desc = "Add 1"
      }

      t2 = AddTransform.new([2, 3]).tap{|t|
        t.stage = "parse"
        t.desc = "Add 2 and 3"
      }

      ProductImport::Framework::TransformPipeline.new.tap{|t|
        t.transforms = [t1,t2]
      }
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
    class AddTransform < ProductImport::Framework::Transform
      def initialize(adds)
        @adds = adds
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

      subject {
      t1 = AddTransform.new([1]).tap{|t|
        t.stage = "parse"
        t.desc = "Add 1"
      }

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
end

