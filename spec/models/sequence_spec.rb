require "spec_helper"

describe Sequence do
  describe ".increment_for" do
    let!(:sequence) { create(:sequence, name: "stuff", value: 5) }

    it "increments the sequence for the given name" do
      expect {
        Sequence.increment_for("stuff")
      }.to change {
        sequence.reload.value
      }.from(5).to(6)
    end

    it "returns the new sequence value of given name" do
      expect(Sequence.increment_for("stuff")).to eq(6)
    end

    it "begins sequence value at 1" do
      expect(Sequence.increment_for("new_sequence")).to eq(1)
    end

    it "rescues key creation race condition" do
      expect(Sequence).to receive(:find_or_create_by!).with(name: "new_sequence").and_raise(ActiveRecord::RecordNotUnique.new("msg"))
      expect(Sequence).to receive(:find_or_create_by!).with(name: "new_sequence").and_return(create(:sequence, name: "new_sequence"))
      expect(Sequence.increment_for("new_sequence")).to eq(1)
    end
  end

  describe ".set_value_for!" do
    it "overides value for given name" do
      expect(Sequence.increment_for("overridden")).to eq(1)
      Sequence.set_value_for!("overridden", 10)
      expect(Sequence.increment_for("overridden")).to eq(11)
    end

    it "returns the value that was set" do
      expect(Sequence.set_value_for!("overridden", 10)).to eq(10)
    end
  end
end
