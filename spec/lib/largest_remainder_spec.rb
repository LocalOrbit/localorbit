require 'spec_helper'

describe LargestRemainder do
  subject { described_class }

  describe ".distribute_shares" do
    
    [
      [ {to_distribute: 10, total: 40, items: { "a" => 20, "b" => 20 }}, {"a"=>5,"b"=>5} ],
      [ {to_distribute: 100, total: 30, items: { "a" => 10, "b" => 10, "c" => 10}}, {"a"=>33,"b"=>33,"c"=>34} ],
      [ {to_distribute: 100, total: 98, items: { 1=>10, 2=>25, 3=>63 }}, {1=>10, 2=>26, 3=>64} ],
    ].each do |input, output|
      it "distributes #{input[:to_distribute]} proportionately amongst #{input[:items].inspect} per their contribution to the total #{input[:total]}" do
        expect(subject.distribute_shares(input)).to eq output
      end
    end

    it "gives all the shares to one item if it's the only one" do
      # total 12345 and a single item w value 9 is not realistic, however it goes to show the rule.
      expect(subject.distribute_shares(to_distribute: 27, total: 12345, items: { 42 => 9 })).to eq( 42 => 27 )
    end

    it "sets all shares to 0 if the total to distribute is 0" do
      expect(subject.distribute_shares(to_distribute: 0, total: 12345, items: { 1=>100,2=>200 })).to eq( 1=>0, 2=>0 )
    end

    it "evenly distributes if total is 0" do
      expect(subject.distribute_shares(to_distribute: 30, total: 0, items: { 1=>12,2=>200,3=>-9 })).to eq( 1=>10, 2=>10, 3=>10 )

    end

    it "discards items w 0 value" do
      res = subject.distribute_shares(
        to_distribute: 100, 
        total: 30, items: { "a" => 10, "b" => 10, "c" => 10, "d" => 0, "e" => 0})
      expect(res).to eq({"a"=>33,"b"=>33,"c"=>34})
    end

  end
end
