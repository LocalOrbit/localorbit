module PackingLabels
describe PackingLabels::Label, wip:true do

  subject { described_class }

  let(:order_info1) { {:foo=>:bar, :products=>["prod a", "prod b"]} }
  let(:order_info2) { {:zig=>:zag, :products=>["prod c"]} }
  let(:order_infos) { [order_info1, order_info2 ] }

  describe ".make_labels" do

    it "creates labels for an array of order_info objects" do 
      expect(subject.make_labels(order_infos)).to eq ([
        {:template=>Label::OrderTemplate, :data=>{:order=>{:foo=>:bar}}},
        {:template=>Label::ProductTemplate, :data=>{:order=>{:foo=>:bar}, :product=>'prod a'}},
        {:template=>Label::ProductTemplate, :data=>{:order=>{:foo=>:bar}, :product=>'prod b'}},

        {:template=>Label::OrderTemplate, :data=>{:order=>{:zig=>:zag}}},
        {:template=>Label::ProductTemplate, :data=>{:order=>{:zig=>:zag}, :product=>'prod c'}}
      ])
    end
  end

  describe ".make_order_labels" do
    it "creates an array of labels from an order_info" do 
      expect(subject.make_order_labels(order_info1)).to eq ([
        {:template=>Label::OrderTemplate, :data=>{:order=>{:foo=>:bar}}},
        {:template=>Label::ProductTemplate, :data=>{:order=>{:foo=>:bar}, :product=>'prod a'}},
        {:template=>Label::ProductTemplate, :data=>{:order=>{:foo=>:bar}, :product=>'prod b'}}
      ])
    end

    it "does not modify the order_info parameter" do
      order_info_original = order_info1.dup
      subject.make_order_labels(order_info1)
      expect(order_info_original).to eq order_info1
    end
  end

  # describe ".make_label" do
  #   it "fits an object into the overall label template" do
  #     info_object = "foo"
  #     expect(subject.make_label("bar", "foo")).to eq({:template=> "bar", :data=> "foo"})
  #   end
  # end
end
end
