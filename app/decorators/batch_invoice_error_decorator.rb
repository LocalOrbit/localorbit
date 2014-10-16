class BatchInvoiceErrorDecorator < Draper::Decorator
  delegate_all

  def description 
    msg = "#{task} - #{message}"
    msg = "#{order.order_number} - #{msg}" if order_id.present?
    msg
  end
end
