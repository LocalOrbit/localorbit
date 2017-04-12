class ProcessConsignmentPrintable
  include Interactor

  def perform
    printable = ConsignmentPrintable.find printable_id
    

  end
end