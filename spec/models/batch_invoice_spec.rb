require 'spec_helper'

describe BatchInvoice, :type => :model do
  subject { create(:batch_invoice) }
  
  it "can be created" do 
    expect(subject).to be
    expect(subject.generation_status).to eq(BatchInvoice::GenerationStatus::NotStarted)
    expect(subject.generation_progress).to eq(0.0)
    expect(subject.user).to be
  end

  it "validates presence of user" do
    subject.user = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:user]).to be
  end

  it "has many Orders" do
    o1 = create(:order)
    o2 = create(:order)
    subject.orders << o1
    subject.orders << o2
    subject.reload
    expect(subject.orders).to contain_exactly(o1,o2)
  end

  it "has a PDF attachment" do
    subject.pdf = "fake data"
    expect(subject.pdf.file.read).to eq("fake data")
    subject.pdf = nil
    subject.save
  end

  it "has batch_invoice_errors" do
    subject.batch_invoice_errors.create(message: "a msg", task: "a task")
    expect(subject).to have(1).batch_invoice_error
    err = subject.batch_invoice_errors.first
    expect(err.message).to eq("a msg")
    expect(err.task).to eq("a task")
  end

  describe ".for_user scope" do
    let!(:user1) { create(:user) }
    let!(:user1_batch_invoices) { create_list(:batch_invoice, 2, user: user1) }
    let!(:user2) { create(:user) }
    let!(:user2_batch_invoices) { create_list(:batch_invoice, 2, user: user2) }

    it "returns the BatchInvoices for the User" do
      expect(BatchInvoice.for_user(user1)).to contain_exactly(*user1_batch_invoices)
    end

    it "allows a user to match their invoices but no others" do
      bi1 = user1_batch_invoices.first
      found = BatchInvoice.for_user(user1).find(bi1.id)
      expect(found).to eq(bi1)

      bi3 = user2_batch_invoices.first
      found = BatchInvoice.for_user(user2).find(bi3.id)
      expect(found).to eq(bi3)
      # User 1 should NOT be able to access this item:
      expect { BatchInvoice.for_user(user1).find(bi3.id) }.to raise_error
    end
  end
  
end
