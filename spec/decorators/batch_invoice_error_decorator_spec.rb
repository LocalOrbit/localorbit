require "spec_helper"

describe BatchInvoiceErrorDecorator do
  let(:error)  { create(:batch_invoice_error, 
                         task: "Building a home", 
                         message: "ran out of nails") }
  let(:order) { create(:order) }
  let(:error_with_order)  { create(:batch_invoice_error, 
                                   task: "Going to market", 
                                   message: "forgot wallet",
                                   order: order) }

  let(:error_with_exception)  { create(:batch_invoice_error, 
                                   task: "Just something bad", 
                                   message: "exceptions and backtraces are for support and devs, not customers",
                                   exception: "BOOM",
                                   backtrace: "line\nnumbers\neverywhere",
                                   order: order) }
  describe "#description" do
    context "with only :task and :message set" do
      it "concats the strings w a dash" do
        expect(error.decorate.description).to eq("Building a home - ran out of nails")
      end
    end

    context "with only :task and :message and :order set" do
      it "concats the strings w a dash" do
        expect(error_with_order.decorate.description).to eq("#{order.order_number} - Going to market - forgot wallet")
      end
    end

    context "with only :exception and :backtrace set" do
      it "concats the strings w a dash" do
        expect(error_with_exception.decorate.description).to eq("#{order.order_number} - Just something bad - exceptions and backtraces are for support and devs, not customers")
      end
    end
  end
end

