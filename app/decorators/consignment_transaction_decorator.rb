class ConsignmentTransactionDecorator < Draper::Decorator

  delegate_all

  def location_info
    if status == 'waiting'
      'Awaiting Delivery'
    else
      #l = Lot.where(id: lot_id).last
      "#{storage_location_name.nil? ? '' : storage_location_name}"
    end
  end

end