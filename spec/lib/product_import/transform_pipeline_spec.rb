require 'spec_helper'

describe ProductImport::TransformPipeline do
  class AddTransform < ProductImport::Transform
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

  describe "With a transformer that can succeed or fail" do
    subject {
      t1 = AddTransform.new([1]).tap{|t|
        t.stage = "parse"
        t.desc = "Add 1"
      }

      t2 = AddTransform.new([2, 3]).tap{|t|
        t.stage = "parse"
        t.desc = "Add 2 and 3"
      }

      ProductImport::TransformPipeline.new.tap{|t|
        t.transforms = [t1,t2]
      }
    }

    it "Can create success/failure sets for an input" do
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
end

