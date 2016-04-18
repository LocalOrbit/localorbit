class UndoMarkDelivered
	include Interactor

	# req? - > (user: current_user, order: order, delivery_id: params.require(:order)[:delivery_id])
	def perform
		order.items.map{|i| i.delivery_status = "pending"; i.quantity_delivered = 0.0; i.delivered_at = nil}
		order.items.map{|i| i.save!}
		order.save!
	end

end