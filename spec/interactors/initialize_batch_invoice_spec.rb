require "spec_helper"

describe InitializeBatchInvoice do
  let!(:user) { create(:user, :buyer) }
  let!(:orders) { [create(:order),create(:order)] }

  subject { described_class }

  it "creates a new BatchInvoice in the database for the given User and links the given Orders" do
    context = subject.perform(user: user, orders:orders)
    batch_invoice = context.batch_invoice

    # See the BI saved to db:
    expect(BatchInvoice.find(batch_invoice.id)).to eq(batch_invoice)

    expect(batch_invoice.user).to eq(user)

    expect(batch_invoice.orders).to contain_exactly(*orders)
  end

  it "requires that you pass in :user and :orders" do
    expect { subject.perform(orders:orders) }.to raise_error(/requires :user/)
    expect { subject.perform(user:user) }.to raise_error(/requires :orders/)
  end

  it "fails for empty :orders with message" do
    context = subject.perform(orders:[],user:user)
    expect(context.success?).to be_falsey
    expect(context.message).to match(/select/)
  end

  it "fails for bad orders and stashes a BatchInvoiceError" do
    bad_order = create(:order)
    bad_order.delivery_zip = nil
    expect(bad_order.valid?).to be_falsey

    context = subject.perform(orders:[bad_order],user:user)
    expect(context.success?).to be_falsey
    expect(context.message).to match(/error/)


    batch_invoices = BatchInvoice.for_user(user)
    expect(batch_invoices.count).to eq(1)
    batch_invoice = batch_invoices.first
    expect(batch_invoice.generation_status).to eq(BatchInvoice::GenerationStatus::Failed)
    bie = batch_invoice.batch_invoice_errors.first
    expect(bie).to be
    expect(bie.task).to match(/initializ/i)
    expect(bie.message).to match(/order ids/i)
    expect(bie.message).to match(/#{bad_order.id}/i)
    expect(bie.exception).to match(/orders/i)
  end


end
