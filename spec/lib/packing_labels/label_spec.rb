require 'spec_helper'

module PackingLabels
describe PackingLabels::Label do

  subject { described_class }

  let(:order_info1) { {:foo=>:bar, :products=>["prod a", "prod b"]} }
  let(:order_info2) { {:zig=>:zag, :products=>["prod c"]} }
  let(:order_infos) { [order_info1, order_info2 ] }
  let(:product_labels_only) { true }
  let(:product_label_format) { 4 }
  let(:print_multiple_labels_per_item) { false }
  let(:order_template) { "avery_labels/vertical_order_4" }
  let(:product_template) { "avery_labels/vertical_product_4" }

  describe ".make_labels" do

    it "creates labels for an array of order_info objects" do
      expect(subject.make_labels(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item)).to eq ([
        {:template=>order_template, :data=>{:order=>{:foo=>:bar}}},
        {:template=>product_template, :data=>{:order=>{:foo=>:bar}, :product=>'prod a'}},
        {:template=>product_template, :data=>{:order=>{:foo=>:bar}, :product=>'prod b'}},
        {:template=>"avery_labels/reset_page", :data=>nil},
        {:template=>order_template, :data=>{:order=>{:zig=>:zag}}},
        {:template=>product_template, :data=>{:order=>{:zig=>:zag}, :product=>'prod c'}},
        {:template=>"avery_labels/page_break", :data=>nil},
        {:template=>"avery_labels/page_break", :data=>nil},
        {:template=>"avery_labels/reset_page", :data=>nil}
      ])
    end
  end

  describe ".make_order_labels" do
    it "creates an array of labels from an order_info" do
      expect(subject.make_order_labels(order_info1, product_labels_only, product_label_format, print_multiple_labels_per_item, order_infos)).to eq ([
        {:template=>order_template, :data=>{:order=>{:foo=>:bar}}},
        {:template=>product_template, :data=>{:order=>{:foo=>:bar}, :product=>'prod a'}},
        {:template=>product_template, :data=>{:order=>{:foo=>:bar}, :product=>'prod b'}},
        {:template=>"avery_labels/reset_page", :data=>nil}
      ])
    end

    it "does not modify the order_info parameter" do
      order_info_original = order_info1.dup
      subject.make_order_labels(order_info1, product_labels_only, product_label_format, print_multiple_labels_per_item, order_infos)
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
