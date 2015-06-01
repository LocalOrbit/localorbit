require 'spec_helper'

describe DataCalc do
  subject(:calc) { described_class }
  
  describe ".sum_of_fields" do
    Measure = Struct.new(:height, :weight)
    let(:measures) {[
      Measure.new(1, BigDecimal.new("100")),
      Measure.new(2, BigDecimal.new("200")),
      Measure.new(3, BigDecimal.new("300")),
    ]}

    context "list of objects" do
      it "sums the values of the target field" do
        expect(calc.sum_of_field(measures,:height)).to eql(6)
        expect(calc.sum_of_field(measures,:weight)).to eql(BigDecimal.new("600"))
      end
    end

    context "empty array" do
      it "returns default" do
        default = BigDecimal.new("12.34")
        expect(calc.sum_of_field([], :wat, default: default)).to eql default
      end
    end

    context "empty array, no default" do
      it "raises" do
        expect { calc.sum_of_field([], :wat) }.to raise_error(/default must be provided/i)
      end
    end

    context "nil arg" do
      it "raises" do
        expect { calc.sum_of_field(nil, :wat) }.to raise_error(/must be a collection/i)
      end
    end
  end

  describe ".sum_of_key" do
    let(:measures) {[
      {height:1, weight:BigDecimal.new("100.1")},
      {height:2, weight:BigDecimal.new("200.2")},
      {height:3, weight:BigDecimal.new("300.3")},
    ]}

    context "list of hashes" do
      it "sums the values of the target key" do
        expect(calc.sum_of_key(measures,:height)).to eql(6)
        expect(calc.sum_of_key(measures,:weight)).to eql(BigDecimal.new("600.6"))
      end
    end

    context "empty array" do
      it "returns default" do
        default = BigDecimal.new("12.34")
        expect(calc.sum_of_key([], :wat, default: default)).to eql default
      end
    end

    context "empty array, no default" do
      it "raises" do
        expect { calc.sum_of_key([], :wat) }.to raise_error(/default must be provided/i)
      end
    end
    context "nil arg" do
      it "raises" do
        expect { calc.sum_of_key(nil, :wat) }.to raise_error(/must be a collection/i)
      end
    end
  end

  describe ".sums_of_keys" do
    let(:measures) {[
      {height:1, weight:BigDecimal.new("100.1")},
      {height:2, weight:BigDecimal.new("200.2")},
      {height:3, weight:BigDecimal.new("300.3")},
    ]}

    context "list of hashes" do
      it "sums the values of the target key" do
        expect(calc.sums_of_keys(measures)).to eql({height: 6, weight: BigDecimal.new("600.6")})
      end

      context "specifying a subset of keys" do
        it "targets only the specified set of keys" do
          expect(calc.sums_of_keys(measures, keys: [:weight])).to eql({weight: BigDecimal.new("600.6")})
          expect(calc.sums_of_keys(measures, keys: [:height])).to eql({height: 6})
        end
      end
    end

    context "list of objects" do
      it "sums the values of the target key" do
        expect(calc.sums_of_keys(measures)).to eql({height: 6, weight: BigDecimal.new("600.6")})
      end
    end

    context "empty array" do
      it "returns default" do
        default = {wat: BigDecimal.new("12.34")}
        expect(calc.sums_of_keys([], default: default)).to eql default
      end
    end

    context "empty array, no default" do
      it "raises" do
        expect { calc.sums_of_keys([]) }.to raise_error(/default must be provided/i)
      end
    end

    context "nil arg" do
      it "raises" do
        expect { calc.sums_of_keys(nil) }.to raise_error(/must be a collection/i)
      end
    end
  end
end
