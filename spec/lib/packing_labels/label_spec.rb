module PackingLabels
describe PackingLabels::Label do

  subject { described_class }

  describe ".make_labels" do
    it "creates labels for an array of order_info objects" do 
      order_infos = [{:foo=>:bar, :products=>[{:baz=>:bif}]}, {:zig=>:zog, :products=>[{:zig=>:zag}]}]
      expect(subject.make_labels(order_infos)).to eq ([
        {:template=>Label::OrderTemplate, :data=>{:foo=>:bar}},
        {:template=>Label::ProductTemplate, :data=>{:baz=>:bif}},
        {:template=>Label::OrderTemplate, :data=>{:zig=>:zog}},
        {:template=>Label::ProductTemplate, :data=>{:zig=>:zag}}
      ])
    end
  end

  describe ".make_order_labels" do
    it "creates an array of labels from an order_info" do 
      order_info = {:foo=>:bar, :products=>[{:baz=>:bif}]}
      expect(subject.make_order_labels(order_info)).to eq ([
        {:template=>Label::OrderTemplate, :data=>{:foo=>:bar}},
        {:template=>Label::ProductTemplate, :data=>{:baz=>:bif}}
      ])
    end

    it "does not modify the order_info parameter" do
      order_info = {:foo=>:bar, :products=>[{:baz=>:bif}]}
      order_info_original = {:foo=>:bar, :products=>[{:baz=>:bif}]}
      subject.make_order_labels(order_info)
      expect(order_info_original).to eq order_info 
    end
  end

  describe ".make_label" do
    it "fits an object into the overall label template" do
      info_object = "foo"
      expect(subject.make_label("bar", "foo")).to eq({:template=> "bar", :data=> "foo"})
    end
  end
end
end
