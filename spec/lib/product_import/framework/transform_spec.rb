require 'spec_helper'

describe ProductImport::Framework::Transform do
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

  describe "With a transformer that can succeed or fail" do
    subject {
      AddTransform.new(
        adds: [1],
        stage: "parse",
        desc: "Add 1"
      )
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

  describe "With a transformer that can succeed multiple times" do
    subject {
      AddTransform.new(
        adds: [1, -1],
        stage: "parse",
        desc: "Add 1 and -1"
      )
    }

    it "Can create success/failure sets for an input" do
      successes, failures = subject.transform_enum([1,:foo, 2,"bar", 3])

      expect(successes).to eq([2,0,3,1,4,2])
      expect(failures.length).to eq(2)

      expect(failures[0]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1 and -1",
        "raw" => :foo,
      })

      expect(failures[1]).to eq({
        "reason" => "Not a number",
        "stage" => "parse",
        "transform" => "Add 1 and -1",
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

