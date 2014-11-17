describe PackingLabels::Page do
  subject { described_class }

  describe ".make_pages" do
    context "4 labels" do
      let(:labels) { %w|label1 label2 label3 label4| }

      it "a single page is produced including the 4 labels" do
        expect(subject.make_pages(labels)).to eq([{
          a: "label1",
          b: "label2",
          c: "label3",
          d: "label4",
        }])
      end
    end

    context "eight labels" do
      let(:labels) { (1..8).to_a.map do |i| "label#{i}" end }

      it "returns 2 pages" do
        expect(subject.make_pages(labels)).to eq([{
          a: "label1",
          b: "label2",
          c: "label3",
          d: "label4",
        }, {
          a: "label5",
          b: "label6",
          c: "label7",
          d: "label8",
        }])
      end
    end

    context "labels not divisible by 4" do
      let(:labels) { (1..6).to_a.map do |i| "label#{i}" end }

      it "returns 2 pages with nil quadrants" do
        expect(subject.make_pages(labels)).to eq([{
          a: "label1",
          b: "label2",
          c: "label3",
          d: "label4",
        }, {
          a: "label5",
          b: "label6",
          c: nil,
          d: nil
        }])
      end
    end

    context "no labels" do
      it "returns a blank page" do
        expect(subject.make_pages([])).to eq([])
      end
    end
  end
end
