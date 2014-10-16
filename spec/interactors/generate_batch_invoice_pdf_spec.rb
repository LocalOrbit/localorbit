require "spec_helper"

describe GenerateBatchInvoicePdf do
  subject { described_class }

  let!(:orders) { [ create(:order), create(:order) ] }
  let!(:batch_invoice) { create(:batch_invoice, orders: orders) } 
  let(:request) { double("Request") }


  let(:temp_file_contexts) {
    [ double("temp-file-result-0", file: "file-0", pdf: "pdf-0", success?:true),
      double("temp-file-result-1", file: "file-1", pdf: "pdf-1", success?:true) ]
  }

  let(:merge_context) {
    double("Merge context", pdf: "the uber PDF")
  }

  it "generates PDFs for all the Orders attached to the BatchInvoice" do
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:start_generation!).
      with(batch_invoice)

    batch_invoice.orders.zip(temp_file_contexts).each.with_index do |(order,ctx),i|
      expect(MakeInvoicePdfTempFile).
        to receive(:perform).
        with(request: request, order: order).
        and_return(ctx)
      expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
        to receive(:update_generation_progress!).
        with(batch_invoice, completed_count: i+1)
    end
    
    expect(MergePdfFiles).
      to receive(:perform).
      with(files:["file-0","file-1"]).
      and_return(merge_context)

    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:complete_generation!).
      with(batch_invoice, pdf: "the uber PDF", pdf_name: "invoices.pdf")

   subject.perform(request: request, batch_invoice: batch_invoice)
  end


  it "records individual PDF generation errors" do
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:start_generation!).
      with(batch_invoice)

    # Rig the first temp file to fail formally:
    temp_file_contexts[0] = double("temp-file-result-0", success?: false, message: "oops")

    # Expect that an error will be recorded for the first order:
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:record_error!).
      with(batch_invoice, task: "Generating invoice PDF", 
                          message: "oops", 
                          order: batch_invoice.orders[0])

    # Still expect to see all orders processes and all progress updates made to BatchInvoice:
    batch_invoice.orders.zip(temp_file_contexts).each.with_index do |(order,ctx),i|
      expect(MakeInvoicePdfTempFile).
        to receive(:perform).
        with(request: request, order: order).
        and_return(ctx)

      expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
        to receive(:update_generation_progress!).
        with(batch_invoice, completed_count: i+1)
    end

    expect(MergePdfFiles).
      to receive(:perform).
      with(files:["file-1"]).   # First PDF should NOT be included because it wasn't successfully generated
      and_return(merge_context)
   
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:complete_generation!).
      with(batch_invoice, pdf: "the uber PDF", pdf_name: "invoices.pdf")

    # Go!
     subject.perform(request: request, batch_invoice: batch_invoice)
  end

  it "records individual PDF generation Exceptions" do
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:start_generation!).
      with(batch_invoice)

    exception = begin; raise("Skadoosh"); rescue => e; e; end

    # Expect that an error will be recorded for the first order:
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:record_error!).
      with(batch_invoice, task: "Generating invoice PDF", 
                          message: "Unexpected exception in MakeInvoicePdfTempFile", 
                          exception: exception.inspect,
                          backtrace: exception.backtrace,
                          order: batch_invoice.orders[0])

    # Still expect to see all orders processes and all progress updates made to BatchInvoice:
    batch_invoice.orders.zip(temp_file_contexts).each.with_index do |(order,ctx),i|
      exp = expect(MakeInvoicePdfTempFile).
              to receive(:perform).
              with(request: request, order: order)
      if i == 0
        # First order should blow up:
        exp.and_raise(exception)
      else
        # Others should work as expected:
        exp.and_return(ctx)
      end

      expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
        to receive(:update_generation_progress!).
        with(batch_invoice, completed_count: i+1)
    end

    expect(MergePdfFiles).
      to receive(:perform).
      with(files:["file-1"]).   # First PDF should NOT be included because it wasn't successfully generated
      and_return(merge_context)
   
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:complete_generation!).
      with(batch_invoice, pdf: "the uber PDF", pdf_name: "invoices.pdf")

    # Go!
     subject.perform(request: request, batch_invoice: batch_invoice)
  end

  it "captures overarching exceptions and records them as errors" do
    # All the loopy stuff build-up stuff will happen normally:
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:start_generation!).
      with(batch_invoice)

    batch_invoice.orders.zip(temp_file_contexts).each.with_index do |(order,ctx),i|
      expect(MakeInvoicePdfTempFile).
        to receive(:perform).
        with(request: request, order: order).
        and_return(ctx)
      expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
        to receive(:update_generation_progress!).
        with(batch_invoice, completed_count: i+1)
    end
    
    exception = begin; raise("Skadoosh major"); rescue => e; e; end

    # Rig the final merge to go BOOM
    expect(MergePdfFiles).
      to receive(:perform).
      with(files:["file-0","file-1"]).
      and_raise(exception)
   
    # Expect that an error will be recorded for the overarching error:
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:record_error!).
      with(batch_invoice, task: "Generating batch invoice PDF", 
                          message: "Unexpected exception while processing and merging invoice PDFs", 
                          exception: exception.inspect,
                          backtrace: exception.backtrace)

    # Instead of being completed, this batch should be failed:
    expect(GenerateBatchInvoicePdf::BatchInvoiceUpdater).
      to receive(:fail_generation!).
      with(batch_invoice)

    # Go!
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
