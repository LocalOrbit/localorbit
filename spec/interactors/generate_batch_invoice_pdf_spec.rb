require "spec_helper"

describe GenerateBatchInvoicePdf do
  subject { described_class }

  let!(:orders) { [ create(:order), create(:order) ] }
  let!(:batch_invoice) { create(:batch_invoice, orders: orders) } 
  let(:request) { double("Request") }

  def expect_updater_start
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:start_generation!).
      with(batch_invoice)
  end

  def expect_generate_and_merge_pdfs(generator_exceptions:{}, merge_exception:nil)
    pdf_file_paths = []

    batch_invoice.orders.each.with_index do |order,i|
      expect(Invoices::InvoicePdfGenerator).to receive(:generate_pdf) do |args|
        expect(args[:request]).to eq request
        expect(args[:order]).to eq order 
        if ex = generator_exceptions[order.id]
          raise ex
        end
        pdf_file_paths << args[:path]
        "some pdf" # not actually used by the batch generator
      end

      expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
        to receive(:update_generation_progress!).
        with(batch_invoice, completed_count: i+1)
    end

    expect(GhostscriptWrapper).to receive(:merge_pdf_files) do |tempfiles|
      expect(tempfiles.map { |f| f.path }).to eq(pdf_file_paths)
      raise merge_exception if merge_exception
      "the merged PDF"
    end
  end

  def expect_updater_complete
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:complete_generation!).
      with(batch_invoice, pdf: "the merged PDF", pdf_name: "invoices.pdf")
  end

  def expect_updater_record_error(order:nil,exception:)
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:record_error!) do |bi, args|
        expect(bi).to eq batch_invoice
        expect(args[:exception]).to eq(exception.inspect)
        expect(args[:backtrace]).to eq(exception.backtrace)
        if order
          expect(args[:order]).to eq(order)
        end
      end
  end

  def expect_updater_fail
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:fail_generation!).
      with(batch_invoice)
  end

  it "generates PDFs for all the Orders attached to the BatchInvoice" do
    expect_updater_start
    expect_generate_and_merge_pdfs
    expect_updater_complete
    subject.perform(request: request, batch_invoice: batch_invoice)
  end


  it "records individual PDF generation Exceptions" do
    broken_order = batch_invoice.orders.first
    exception = begin; raise("Skadoosh"); rescue => e; e; end

    expect_updater_start
    expect_generate_and_merge_pdfs(
      generator_exceptions: {broken_order.id => exception}
    )
    expect_updater_record_error(order: broken_order, exception: exception)
    expect_updater_complete
    subject.perform(request: request, batch_invoice: batch_invoice)
  end

  it "captures overarching exceptions and records them as errors" do
    exception = begin; raise("Skadoosh major"); rescue => e; e; end

    expect_updater_start
    expect_generate_and_merge_pdfs(
      merge_exception: exception
    )
    expect_updater_record_error(exception: exception)
    expect_updater_fail

    subject.perform(request: request, batch_invoice: batch_invoice)
  end


  #
  # BatchInvoiceUpdater
  #

  describe GenerateBatchInvoicePdf::BatchInvoiceUpdater do
    describe ".start_generation!" do
      it "sets progress to 0 and status to 'generating'" do
        batch_invoice.update!(generation_progress: 0.3, generation_status: BatchInvoice::GenerationStatus::NotStarted)

        subject.start_generation!(batch_invoice)
        expect(batch_invoice.generation_progress).to eq(0)
        expect(batch_invoice.generation_status).to eq(BatchInvoice::GenerationStatus::Generating)
      end
    end

    describe ".update_generation_progress!" do
      it "recalcs generation progress based on completed items vs. expected total" do
        expect(batch_invoice.generation_progress).to eq(0)

        subject.update_generation_progress!(batch_invoice, completed_count: 1)
        expect(batch_invoice.generation_progress).to eq(0.5)

        subject.update_generation_progress!(batch_invoice, completed_count: 2)
        expect(batch_invoice.generation_progress).to eq(1.0)
      end
    end

    describe ".complete_generation!" do
      it "sets the pdf and finalizes generation status and progress" do
        batch_invoice.update!(generation_status: BatchInvoice::GenerationStatus::Generating,
                              generation_progress: 0.75)

        subject.complete_generation!(batch_invoice, pdf: "some pdf content", pdf_name: "thefilename.pdf")

        batch_invoice.reload
        expect(batch_invoice.pdf).to be
        expect(batch_invoice.pdf.file.read).to eq("some pdf content")
        expect(batch_invoice.pdf.name).to eq("thefilename.pdf")
        expect(batch_invoice.generation_progress).to eq(1.0)
        expect(batch_invoice.generation_status).to eq(BatchInvoice::GenerationStatus::Complete)
      end
    end

    describe ".record_error!" do
      let!(:order) { create(:order) }

      it "adds a BatchInvoiceError record to the given BatchInvoice, referencing an Order" do
        expect(batch_invoice.batch_invoice_errors).to be_empty

        subject.record_error!(batch_invoice, task: "The task", message: "The message", order: order)
        batch_invoice.reload
        expect(batch_invoice).to have(1).batch_invoice_error

        error0 = batch_invoice.batch_invoice_errors.first
        expect(error0.task).to eq("The task")
        expect(error0.message).to eq("The message")
        expect(error0.order).to eq(order)
        expect(error0.exception).to be_nil
        expect(error0.backtrace).to be_nil
      end

      it "can be built without an Order" do
        expect(batch_invoice.batch_invoice_errors).to be_empty

        subject.record_error!(batch_invoice, task: "The task", message: "The message")
        batch_invoice.reload
        expect(batch_invoice).to have(1).batch_invoice_error

        error0 = batch_invoice.batch_invoice_errors.first
        expect(error0.task).to eq("The task")
        expect(error0.message).to eq("The message")
        expect(error0.order).to be_nil
        expect(error0.exception).to be_nil
        expect(error0.backtrace).to be_nil
      end

      it "can have an exception and backtrace" do
        expect(batch_invoice.batch_invoice_errors).to be_empty

        subject.record_error!(batch_invoice, task: "The task", 
                                             message: "The message", 
                                             exception: "The exception", 
                                             backtrace: "The backtrace", 
                                             order: order)
        batch_invoice.reload
        expect(batch_invoice).to have(1).batch_invoice_error

        error0 = batch_invoice.batch_invoice_errors.first
        expect(error0.task).to eq("The task")
        expect(error0.message).to eq("The message")
        expect(error0.order).to eq(order)
        expect(error0.exception).to eq("The exception")
        expect(error0.backtrace).to eq("The backtrace")
      end

      it "converts backtrace arrays into strings w newlines" do
        subject.record_error!(batch_invoice, task: "The task", 
                                             message: "The message", 
                                             backtrace: ["an", "list", "of"])
        batch_invoice.reload
        error0 = batch_invoice.batch_invoice_errors.first
        expect(error0.backtrace).to eq("an\nlist\nof")
      end
    end

    describe ".fail_generation!" do
      it "sets fail status on the batch invoice" do
        progress = "0.37".to_d
        batch_invoice.update!(generation_progress: progress)

        subject.fail_generation!(batch_invoice)
        expect(batch_invoice.generation_progress).to eq(progress) #see progress unchanged
        expect(batch_invoice.generation_status).to eq(BatchInvoice::GenerationStatus::Failed)
      end
    end
  end

end
