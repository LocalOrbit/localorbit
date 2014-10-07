require 'spec_helper'

describe BatchInvoiceError, :type => :model do
  subject { create(:batch_invoice_error) }

  it "exists" do
    expect(subject).to be
    expect(subject.task).to be_nil
    expect(subject.message).to be_nil
    expect(subject.exception).to be_nil
    expect(subject.backtrace).to be_nil
    expect(subject.batch_invoice_id).to be_nil
    expect(subject.order_id).to be_nil
  end

  it "can be linked to a BatchInvoice" do
    x = create(:batch_invoice)
    subject.update!(batch_invoice: x)
    subject.reload
    expect(subject.batch_invoice).to eq(x)
  end
  it "can be linked to an Order" do
    x = create(:order)
    subject.update!(order: x)
    subject.reload
    expect(subject.order).to eq(x)
  end
end
