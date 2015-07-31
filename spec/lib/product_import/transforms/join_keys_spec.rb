require 'spec_helper'

describe ProductImport::Transforms::JoinKeys do
  describe "defined 'with'" do
    subject {
      described_class.new(
        keys: ["FOO", "BAR", "BAZ"],
        with: ' - ',
        into: "foobar"
      )
    }

    it "concatenates the contents of several keys into one output field" do
      data = [
        {"FOO"=>"a", "BAR"=>"b", "BAZ"=>"c"},
        {"BAR"=>"b"},
        {"FOO"=>" ", "BAR"=>"b", "BAZ"=>"c"},
        {"FOO"=>" ", "BAR"=>"b", "BAZ"=>" "}
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(4)
      expect(successes[0]["foobar"]).to eq("a - b - c")
      expect(successes[1]["foobar"]).to eq("b")
      expect(successes[2]["foobar"]).to eq("b - c")
      expect(successes[3]["foobar"]).to eq("b")

      expect(failures.size).to eq(0)
    end
  end

  describe "undefined 'with'" do
    subject {
      described_class.new(
        keys: ["FOO", "BAR", "BAZ"],
        into: "foobar"
      )
    }

    it "concatenates the contents of several keys into one output field" do
      data = [
        {"FOO"=>"a", "BAR"=>"b", "BAZ"=>"c"},
      ]

      successes, failures = subject.transform_enum(data)

      expect(successes.size).to eq(1)
      expect(successes[0]["foobar"]).to eq("a b c")

      expect(failures.size).to eq(0)
    end
  end

end
