class ConsignmentTransactionDecorator < Draper::Decorator

  delegate_all

  def location_info
    if status == 'waiting'
      'Awaiting Delivery'
    else
      l = Lot.where(id: lot_id).last
      "#{l.storage_location.nil? ? '' : l.storage_location.name}"
    end
  end

end